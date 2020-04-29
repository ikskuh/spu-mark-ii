const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");

usingnamespace @import("spu-mk2");

const FileFormat = enum { ihex, binary };

pub fn main() !u8 {
    const cli_args = try argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        format: ?FileFormat = .binary,
        output: []const u8 = "a.out",

        pub const shorthands = .{
            .h = "help",
            .f = "format",
            .o = "output",
        };
    }, std.heap.page_allocator);
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len == 0) {
        try std.io.getStdOut().outStream().writeAll(
            \\assembler --help [--format ihex|binary] [--output file] fileA fileB …
            \\Assembles code for the SPU Mark II platform.
            \\
            \\-h, --help     Displays this help text.
            \\-f, --format   Selects the output format (binary or ihex).
            \\               If not given, the assembler will emit raw binaries.
            \\-o, --output   Defines the name of the output file. If not given,
            \\               the assembler will chose a.out as the output file name.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else @as(u8, 1);
    }

    var assembler = Assembler.init(std.heap.page_allocator);
    defer assembler.deinit();

    for (cli_args.positionals) |path| {
        var file = try std.fs.cwd().openFile(path, .{ .read = true, .write = false });
        defer file.close();

        try assembler.assemble(path, file.inStream());
    }

    return 1;
}

pub const Patch = struct {
    offset: u16,
};

pub const Section = struct {
    start: u16,
    bytes: std.ArrayList(u8),
    patches: std.ArrayList(Patch),
};

const Modifiers = struct {
    const Self = @This();

    condition: ?ExecutionCondition = null,
    input0: ?InputBehaviour = null,
    input1: ?InputBehaviour = null,
    modify_flags: ?bool = null,
    output: ?OutputBehaviour = null,
    command: ?Command = null,

    /// will start at identifier, not `[`!
    fn parse(mods: *Self, parser: *Parser) !void {
        const mod_type = try parser.expect(.label); // type + ':'
        const mod_value = try parser.expect(.identifier); // value
        _ = try parser.expect(.closing_brackets);

        if (std.mem.eql(u8, mod_type.text, "ex:")) {
            if (mods.condition != null)
                return error.DuplicateModifier;
            inline for (condition_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.condition = item[1];
                    return;
                }
            }
        } else if (std.mem.eql(u8, mod_type.text, "i0:")) {
            if (mods.input0 != null)
                return error.DuplicateModifier;
            inline for (input_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.input0 = item[1];
                    return;
                }
            }
        } else if (std.mem.eql(u8, mod_type.text, "i1:")) {
            if (mods.input1 != null)
                return error.DuplicateModifier;
            inline for (input_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.input0 = item[1];
                    return;
                }
            }
        } else if (std.mem.eql(u8, mod_type.text, "f:")) {
            if (mods.modify_flags != null)
                return error.DuplicateModifier;
            inline for (flag_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.modify_flags = item[1];
                    return;
                }
            }
        } else if (std.mem.eql(u8, mod_type.text, "out:")) {
            if (mods.output != null)
                return error.DuplicateModifier;
            inline for (output_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.output = item[1];
                    return;
                }
            }
        } else if (std.mem.eql(u8, mod_type.text, "out:")) {
            if (mods.command != null)
                return error.DuplicateModifier;
            inline for (command_items) |item| {
                if (std.mem.eql(u8, item[0], mod_value.text)) {
                    mods.command = item[1];
                    return;
                }
            }
        }
        return error.InvalidModifier;
    }

    const condition_items = .{
        .{ "always", .always },
        .{ "zero", .when_zero },
        .{ "nonzero", .not_zero },
        .{ "greater", .greater_zero },
        .{ "less", .less_than_zero },
        .{ "gequal", .greater_or_equal_zero },
        .{ "lequal", .less_or_equal_zero },
        .{ "ovfl", .overflow },
    };

    const flag_items = .{
        .{ "no", false },
        .{ "yes", true },
    };

    const input_items = .{
        .{ "zero", .zero },
        .{ "immediate", .immediate },
        .{ "peek", .peek },
        .{ "pop", .pop },
        .{ "arg", .immediate },
        .{ "imm", .immediate },
    };

    const output_items = .{
        .{ "discard", .discard },
        .{ "push", .push },
        .{ "jmp", .jump },
        .{ "rjmp", .jump_relative },
    };

    const command_items = .{
        .{ "copy", .copy },
        .{ "ipget", .ipget },
        .{ "get", .get },
        .{ "set", .set },
        .{ "store8", .store8 },
        .{ "store16", .store16 },
        .{ "load8", .load8 },
        .{ "load16", .load16 },
        .{ "undefined0", .undefined0 },
        .{ "undefined1", .undefined1 },
        .{ "frget", .frget },
        .{ "frset", .frset },
        .{ "bpget", .bpget },
        .{ "bpset", .bpset },
        .{ "spget", .spget },
        .{ "spset", .spset },
        .{ "add", .add },
        .{ "sub", .sub },
        .{ "mul", .mul },
        .{ "div", .div },
        .{ "mod", .mod },
        .{ "and", .@"and" },
        .{ "or", .@"or" },
        .{ "xor", .xor },
        .{ "not", .not },
        .{ "signext", .signext },
        .{ "rol", .rol },
        .{ "ror", .ror },
        .{ "bswap", .bswap },
        .{ "asr", .asr },
        .{ "lsl", .lsl },
        .{ "lsr", .lsr },
    };
};

pub const Assembler = struct {
    const Self = @This();

    allocator: std.heap.ArenaAllocator,

    pub fn init(allocator: *std.mem.Allocator) Assembler {
        return Self{
            .allocator = std.heap.ArenaAllocator.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.deinit();
        self.* = undefined;
    }

    pub fn assemble(self: *Assembler, fileName: []const u8, stream: var) !void {
        var parser = try Parser.fromStream(&self.allocator.allocator, stream);
        defer parser.deinit();

        while (true) {
            const token = try parser.peek();

            if (token == null) // end of file
                break;

            switch (token.?.type) {
                // process directive
                .dot_identifier => try parseDirective(self, &parser),

                // label,
                .label => _ = try parser.expect(.label),

                // modifier
                .identifier, .opening_brackets => try parseInstruction(self, &parser),

                // empty line, skip those
                .line_break => _ = try parser.expect(.line_break),

                else => return error.UnexpectedToken,
            }
        }
    }

    fn getInstructionForMnemonic(name: []const u8, argc: usize) ?Instruction {
        const mnemonics = @import("mnemonics.zig").mnemonics;
        for (mnemonics) |mnemonic| {
            if (mnemonic.argc == argc and std.mem.eql(u8, mnemonic.name, name))
                return mnemonic.instruction;
        }
        return null;
    }

    fn parseInstruction(assembler: *Assembler, parser: *Parser) !void {
        var modifiers = Modifiers{};
        var instruction_name: []const u8 = "";

        // parse modifiers and
        while (true) {
            var tok = try parser.expectAny(.{
                .identifier, // label or equ
                .opening_brackets, // modifier
            });
            switch (tok.type) {
                .identifier => {
                    instruction_name = tok.text;
                    break;
                },
                .opening_brackets => try modifiers.parse(parser),
                else => unreachable, // parse expression
            }
        }

        var operands: [2]Expression = undefined;
        var operand_count: usize = 0;

        var end_of_operands = false;
        // parse modifiers and operands
        while (true) {
            var tok = try parser.peek();
            if (tok == null)
                break;
            switch (tok.?.type) {
                .line_break => {
                    _ = parser.expect(.line_break) catch unreachable;
                    break;
                },
                .opening_brackets => {
                    _ = parser.expect(.opening_brackets) catch unreachable;
                    try modifiers.parse(parser);
                },
                else => {
                    if (operand_count >= operands.len or end_of_operands) {
                        return error.UnexpectedOperand;
                    }
                    const expr_result = try parser.parseExpression(&assembler.allocator.allocator, .{ .line_break, .comma, .opening_brackets });
                    operands[operand_count] = expr_result.expression;
                    operand_count += 1;
                    switch (expr_result.terminator.type) {
                        .line_break => break,
                        .opening_brackets => {
                            try modifiers.parse(parser);
                            end_of_operands = true;
                        },
                        .comma => {},
                        else => unreachable,
                    }
                },
            }
        }

        // search for instruction template
        var instruction = getInstructionForMnemonic(instruction_name, operand_count) orelse {
            if (std.builtin.mode == .Debug) {
                std.debug.warn("unknown mnemonic: {}\n", .{instruction_name});
            }
            return error.UnknownMnemonic;
        };

        // apply modifiers
        inline for (std.meta.fields(Modifiers)) |fld| {
            if (@field(modifiers, fld.name)) |mod| {
                @field(instruction, fld.name) = mod;
            }
        }

        // emit results
        try assembler.emitU16(@bitCast(u16, instruction));

        {
            var i: usize = 0;
            while (i < operand_count) : (i += 1) {
                try assembler.emitExpr(operands[i]);
            }
        }
    }

    fn parseDirective(assembler: *Assembler, parser: *Parser) !void {
        var token = try parser.expect(.dot_identifier);

        inline for (std.meta.declarations(Self)) |decl| {
            if (decl.data != .Fn)
                continue;
            if (decl.name[0] != '.')
                continue;
            if (std.mem.eql(u8, decl.name, token.text)) {
                try @field(Self, decl.name)(assembler, parser);
                return;
            }
        }

        if (std.builtin.mode == .Debug) {
            std.debug.warn("unknown directive: {}\n", .{token.text});
        }

        return error.UnknownDirective;
    }

    // Directives:

    fn @".org"(assembler: *Assembler, parser: *Parser) !void {
        const offset_expr = try parser.parseExpression(&assembler.allocator.allocator, .{.line_break});
    }

    fn @".ascii"(assembler: *Assembler, parser: *Parser) !void {
        const string_expr = try parser.parseExpression(&assembler.allocator.allocator, .{.line_break});
    }

    fn @".asciiz"(assembler: *Assembler, parser: *Parser) !void {
        const string_expr = try parser.parseExpression(&assembler.allocator.allocator, .{.line_break});

        try assembler.emitU8(0x00); // null terminator
    }

    fn @".align"(assembler: *Assembler, parser: *Parser) !void {
        const alignment_expr = try parser.parseExpression(&assembler.allocator.allocator, .{.line_break});
    }

    fn @".dw"(assembler: *Assembler, parser: *Parser) !void {
        while (true) {
            const value_expr = try parser.parseExpression(&assembler.allocator.allocator, .{ .line_break, .comma });

            try assembler.emitExpr(value_expr.expression);

            if (value_expr.terminator.type == .line_break)
                break;
        }
    }

    fn @".db"(assembler: *Assembler, parser: *Parser) !void {
        while (true) {
            const value_expr = try parser.parseExpression(&assembler.allocator.allocator, .{ .line_break, .comma });

            try assembler.emitU8(0xFF);

            if (value_expr.terminator.type == .line_break)
                break;
        }
    }

    // Output handling:

    fn emit(assembler: *Assembler, bytes: []const u8) !void {
        // discard for now…
    }

    fn emitU8(assembler: *Assembler, value: u8) !void {
        const bytes = [1]u8{value};
        try assembler.emit(&bytes);
    }

    fn emitU16(assembler: *Assembler, value: u16) !void {
        var bytes: [2]u8 = undefined;
        std.mem.writeIntLittle(u16, &bytes, value);
        try assembler.emit(&bytes);
    }

    // Consumes a expression and takes ownership of its resources
    fn emitExpr(assembler: *Assembler, expression: Expression) !void {
        var copy = expression;
        errdefer copy.deinit();

        if (assembler.evaluate(copy)) |value| {
            if (value != .number)
                return error.TypeMismatch;
            try assembler.emitU16(value.number);
            defer copy.deinit();
        } else |err| switch (err) {
            error.MissingIdentifiers => {
                // Defer evaluation to end of assembling,
                // store label context (for locals) and expr for later, write dummy value
                try assembler.emitU16(0x5555);
                unreachable;
            },
            else => return err,
        }
    }

    // Expression handling

    fn evaluate(assembler: *Assembler, expression: Expression) !Value {
        // return error.MissingIdentifiers;
        unreachable;
    }

    const Value = union(enum) {
        string: []u8, // does not need to be freed, will be string-pooled
        number: u16,
    };
};

pub const TokenType = enum {
    whitespace,
    comment, // ; …
    line_break, // "\n"

    identifier, // fooas2_3
    dot_identifier, // .fooas2_3
    label, //foobar:, .foobar:

    bin_number, // 0b0000
    oct_number, // 0o0000
    dec_number, // 0000
    hex_number, // 0x0000

    char_literal, // 'A', '\n'
    string_literal, // "Abc", "a\nc"

    dot, // .
    colon, // :
    comma, // ,
    opening_parens, // (
    closing_parens, // )
    opening_brackets, // [
    closing_brackets, // ]

    operator_plus, // +
    operator_minus, // -
    operator_multiply, // *
    operator_divide, // /
    operator_modulo, // %
    operator_bitand, // &
    operator_bitor, // |
    operator_bitxor, // ^
    operator_shl, // <<
    operator_shr, // >>
    operator_asr, // >>>
    operator_bitnot, // ~
};

pub const Token = struct {
    text: []const u8,
    type: TokenType,
};

pub const Parser = struct {
    allocator: ?*std.mem.Allocator,
    source: []u8,
    offset: usize,
    peeked_token: ?Token,

    const Self = @This();

    fn fromStream(allocator: *std.mem.Allocator, stream: var) !Self {
        return Self{
            .allocator = allocator,
            .source = try stream.readAllAlloc(allocator, 16 << 20), // 16 MB
            .offset = 0,
            .peeked_token = null,
        };
    }

    fn fromSlice(text: []const u8) Self {
        return Self{
            .allocator = null,
            .source = text,
            .offset = 0,
            .peeked_token = null,
        };
    }

    fn deinit(self: *Self) void {
        if (self.allocator) |a|
            a.free(self.source);
        self.* = undefined;
    }

    fn expect(parser: *Self, t: TokenType) !Token {
        const tok = (try parser.parse()) orelse return error.UnexpectedEndOfFile;
        if (tok.type == t)
            return tok;
        if (std.builtin.mode == .Debug) {
            std.debug.warn("Unexpected token: {}\nexpected: {}\n", .{
                tok,
                t,
            });
        }
        return error.UnexpectedToken;
    }

    fn expectAny(parser: *Self, types: var) !Token {
        const tok = (try parser.parse()) orelse return error.UnexpectedEndOfFile;
        inline for (types) |t| {
            if (tok.type == @as(TokenType, t))
                return tok;
        }
        if (std.builtin.mode == .Debug) {
            std.debug.warn("Unexpected token: {}\nexpected one of: {}\n", .{
                tok,
                types,
            });
        }
        return error.UnexpectedToken;
    }

    fn peek(parser: *Self) !?Token {
        if (parser.peeked_token) |tok| {
            return tok;
        }
        parser.peeked_token = try parser.parse();
        return parser.peeked_token;
    }

    fn parse(parser: *Self) !?Token {
        if (parser.peeked_token) |tok| {
            parser.peeked_token = null;
            return tok;
        }

        while (true) {
            var token = try parser.parseRaw();
            if (token) |tok| {
                switch (tok.type) {
                    .whitespace => continue,
                    .comment => continue,
                    else => return tok,
                }
            } else {
                return null;
            }
        }
    }

    fn singleCharToken(parser: *Self, t: TokenType) Token {
        return Token{
            .text = parser.source[parser.offset..][0..1],
            .type = t,
        };
    }

    fn isWordCharacter(c: u8) bool {
        return switch (c) {
            'a'...'z' => true,
            'A'...'Z' => true,
            '0'...'9' => true,
            '_' => true,
            else => false,
        };
    }

    fn isDigit(c: u8, number_format: TokenType) bool {
        return switch (number_format) {
            .dec_number => switch (c) {
                '0'...'9' => true,
                else => false,
            },
            .oct_number => switch (c) {
                '0'...'7' => true,
                else => false,
            },
            .bin_number => switch (c) {
                '0', '1' => true,
                else => false,
            },
            .hex_number => switch (c) {
                '0'...'9' => true,
                'a'...'f' => true,
                'A'...'F' => true,
                else => false,
            },
            else => unreachable,
        };
    }

    fn parseRaw(parser: *Self) !?Token {
        if (parser.offset >= parser.source.len)
            return null;
        var token = switch (parser.source[parser.offset]) {
            '\n' => parser.singleCharToken(.line_break),
            ' ', '\t', '\r' => parser.singleCharToken(.whitespace),
            ';' => blk: {
                var off = parser.offset;
                while (off < parser.source.len and parser.source[off] != '\n') {
                    off += 1;
                }
                break :blk Token{
                    .type = .comment,
                    .text = parser.source[parser.offset..off],
                };
            },

            ':' => parser.singleCharToken(.colon),
            ',' => parser.singleCharToken(.comma),
            '(' => parser.singleCharToken(.opening_parens),
            ')' => parser.singleCharToken(.closing_parens),
            '[' => parser.singleCharToken(.opening_brackets),
            ']' => parser.singleCharToken(.closing_brackets),

            '+' => parser.singleCharToken(.operator_plus),
            '-' => parser.singleCharToken(.operator_minus),
            '*' => parser.singleCharToken(.operator_multiply),
            '/' => parser.singleCharToken(.operator_divide),
            '%' => parser.singleCharToken(.operator_modulo),
            '&' => parser.singleCharToken(.operator_bitand),
            '|' => parser.singleCharToken(.operator_bitor),
            '^' => parser.singleCharToken(.operator_bitxor),

            '~' => parser.singleCharToken(.operator_bitnot),

            '.' => if (parser.offset + 1 >= parser.source.len or !isWordCharacter(parser.source[parser.offset + 1]))
                parser.singleCharToken(.dot)
            else blk: {
                var off = parser.offset + 1;
                while (off < parser.source.len and isWordCharacter(parser.source[off])) {
                    off += 1;
                }
                if (off < parser.source.len and parser.source[off] == ':') {
                    off += 1;
                    break :blk Token{
                        .type = .label,
                        .text = parser.source[parser.offset..off],
                    };
                } else {
                    break :blk Token{
                        .type = .dot_identifier,
                        .text = parser.source[parser.offset..off],
                    };
                }
            },

            // operator_shr, // >>
            // operator_asr, // >>>

            // '<<' => parser.singleCharToken(.operator_shl),

            // bin_number: 0b0000
            // oct_number: 0o0000
            // dec_number: 0000
            // hex_number: 0x0000
            '0'...'9' => blk: {
                if (parser.offset + 1 < parser.source.len) {
                    const spec = parser.source[parser.offset + 1];
                    switch (spec) {
                        'x', 'o', 'b' => {
                            var num_type: TokenType = switch (spec) {
                                'x' => .hex_number,
                                'b' => .bin_number,
                                'o' => .oct_number,
                                else => unreachable,
                            };

                            var off = parser.offset + 2;
                            while (off < parser.source.len and isDigit(parser.source[off], num_type)) {
                                off += 1;
                            }
                            // .dotword
                            break :blk Token{
                                .type = num_type,
                                .text = parser.source[parser.offset..off],
                            };
                        },
                        '0'...'9' => {
                            var off = parser.offset + 1;
                            while (off < parser.source.len and isDigit(parser.source[off], .dec_number)) {
                                off += 1;
                            }
                            // .dotword
                            break :blk Token{
                                .type = .dec_number,
                                .text = parser.source[parser.offset..off],
                            };
                        },
                        else => break :blk Token{
                            .type = .dec_number,
                            .text = parser.source[parser.offset .. parser.offset + 1],
                        },
                    }
                } else {
                    break :blk Token{
                        .type = .dec_number,
                        .text = parser.source[parser.offset .. parser.offset + 1],
                    };
                }
            },

            // identifier
            'a'...'z', 'A'...'Z', '_' => blk: {
                var off = parser.offset;
                while (off < parser.source.len and isWordCharacter(parser.source[off])) {
                    off += 1;
                }
                if (off < parser.source.len and parser.source[off] == ':') {
                    off += 1;
                    break :blk Token{
                        .type = .label,
                        .text = parser.source[parser.offset..off],
                    };
                } else {
                    break :blk Token{
                        .type = .identifier,
                        .text = parser.source[parser.offset..off],
                    };
                }
            },

            // string_literal
            '\"' => blk: {
                var off = parser.offset + 1;
                if (off == parser.source.len)
                    return error.IncompleteStringLiteral;

                while (parser.source[off] != '\"') {
                    if (parser.source[off] == '\n')
                        return error.IncompleteStringLiteral;
                    if (parser.source[off] == '\\') {
                        off += 1;
                    }
                    off += 1;
                    if (off >= parser.source.len)
                        return error.IncompleteStringLiteral;
                }
                off += 1;

                break :blk Token{
                    .type = .string_literal,
                    .text = parser.source[parser.offset..off],
                };
            },

            // character_literal
            '\'' => blk: {
                var off = parser.offset + 1;
                if (off >= parser.source.len)
                    return error.IncompleteCharacterLiteral;
                if (parser.source[off] == '\\') {
                    // escaped
                    off += 1;
                    if (off >= parser.source.len)
                        return error.IncompleteCharacterLiteral;
                }
                off += 1;
                if (off >= parser.source.len)
                    return error.IncompleteCharacterLiteral;
                if (parser.source[off] != '\'')
                    return error.IncompleteCharacterLiteral;
                off += 1;

                break :blk Token{
                    .type = .string_literal,
                    .text = parser.source[parser.offset..off],
                };
            },

            else => |c| {
                if (std.builtin.mode == .Debug) {
                    std.debug.warn("unrecognized character: {c}\n", .{c});
                }
                return error.UnrecognizedCharacter;
            },
        };

        parser.offset += token.text.len;

        return token;
    }

    // parses an expression from the token stream
    const ParseExpressionResult = struct {
        expression: Expression,
        terminator: Token,
    };
    fn parseExpression(parser: *Parser, allocator: *std.mem.Allocator, terminators: var) !ParseExpressionResult {
        var tok = try parser.expectAny(.{
            .dec_number,
            .hex_number,
            .oct_number,
            .bin_number,
            .dot,
            .identifier,
            .char_literal,
            .string_literal,
        });
        const terminator = try parser.expectAny(terminators);

        const toks = try allocator.alloc(Token, 1);
        toks[0] = tok;

        return ParseExpressionResult{
            .expression = Expression{
                .allocator = allocator,
                .sequence = toks,
            },
            .terminator = terminator,
        };
    }
};

/// A sequence of tokens created with a shunting yard algorithm.
/// Can be parsed/executed left-to-right
const Expression = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    sequence: []Token,

    fn deinit(expr: *Expression) void {
        expr.allocator.free(expr.sequence);
        expr.* = undefined;
    }
};
