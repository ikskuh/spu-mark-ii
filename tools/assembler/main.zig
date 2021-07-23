const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");

usingnamespace @import("spu-mk2");

const FileFormat = enum { ihex, binary };

pub fn main() !u8 {
    const cli_args = argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        format: ?FileFormat = .binary,
        output: []const u8 = "a.out",

        pub const shorthands = .{
            .h = "help",
            .f = "format",
            .o = "output",
        };
    }, std.heap.page_allocator, .print) catch return 1;
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len == 0) {
        try std.io.getStdOut().writer().writeAll(
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    var assembler = try Assembler.init(&arena.allocator);
    defer assembler.deinit();

    var root_dir = try std.fs.cwd().openDir(".", .{ .access_sub_paths = true, .iterate = false });
    defer root_dir.close();

    for (cli_args.positionals) |path| {
        var file = try root_dir.openFile(path, .{ .read = true, .write = false });
        defer file.close();

        var dir = try root_dir.openDir(std.fs.path.dirname(path) orelse ".", .{ .access_sub_paths = true, .iterate = false });
        defer dir.close();

        try assembler.assemble(path, dir, file.reader());
    }

    try assembler.finalize();

    if (assembler.errors.items.len > 0) {
        const stdout = std.io.getStdOut().writer();

        try stdout.writeAll("Errors appeared while assembling:\n");

        for (assembler.errors.items) |err| {
            try stdout.print("{s}: {s}:{}:{}: {s}\n", .{
                @tagName(err.type),
                "f", //err.location.?.file,
                err.location.?.line,
                err.location.?.column,
                err.message,
            });
        }

        return 1;
    }

    {
        var file = try root_dir.createFile(cli_args.options.output, .{ .truncate = true, .exclusive = false });
        defer file.close();

        var outstream = file.writer();

        var iter = assembler.sections.first;
        while (iter) |section_node| : (iter = section_node.next) {
            const section = &section_node.data;

            var i: usize = 0;

            while (i < section.bytes.items.len) : (i += 16) {
                const length = std.math.min(section.bytes.items.len - i, 16);

                const source = section.bytes.items[i..][0..length];

                var buffer: [256 + 5]u8 = undefined;
                std.mem.writeIntBig(u8, buffer[0..][0..1], @intCast(u8, length));
                std.mem.writeIntBig(u16, buffer[1..][0..2], @intCast(u16, section.offset + i));
                std.mem.writeIntBig(u8, buffer[3..][0..1], 0x00); // data record
                std.mem.copy(u8, buffer[4..], source);

                var checksum: u8 = 0;
                for (buffer[0 .. 4 + length]) |b| {
                    checksum -%= b;
                }
                std.mem.writeIntBig(u8, buffer[4 + length ..][0..1], checksum); // data record

                // data records
                try outstream.print(
                    ":{}\n",
                    .{std.fmt.fmtSliceHexUpper(buffer[0 .. length + 5])},
                );
            }
        }

        // file/stream terminator
        try outstream.writeAll(":00000001FF\n");
    }

    return 0;
}

pub const Patch = struct {
    offset: u16,
    value: Expression,
    locals: *std.StringHashMap(u16),
};

pub const Section = struct {
    const Self = @This();

    offset: u16,
    bytes: std.ArrayList(u8),
    patches: std.ArrayList(Patch),
    dot_offset: u16,

    fn deinit(self: *Self) void {
        self.bytes.deinit();
        for (self.patches.items) |*patch| {
            patch.value.deinit();
        }
        self.patches.deinit();
        self.* = undefined;
    }

    fn getLocalOffset(sect: Self) u16 {
        return @intCast(u16, sect.bytes.items.len);
    }

    fn getGlobalOffset(sect: Self) u16 {
        return @intCast(u16, sect.offset + sect.bytes.items.len);
    }

    fn getDotOffset(sect: Self) u16 {
        return sect.dot_offset;
    }
};

pub const CompileError = struct {
    pub const Type = enum { @"error", warning };

    location: ?Location,
    message: []const u8,
    type: Type,
};

pub const Assembler = struct {
    const Self = @This();
    const SectionNode = std.TailQueue(Section).Node;

    // utilities
    allocator: *std.mem.Allocator,

    // string interning
    string_arena: std.heap.ArenaAllocator,
    interned_strings: std.StringHashMapUnmanaged(void),

    // assembling result
    sections: std.TailQueue(Section),
    symbols: std.StringHashMap(u16),
    local_symbols: *std.StringHashMap(u16),
    errors: std.ArrayList(CompileError),

    // in-flight symbols
    fileName: []const u8,
    directory: ?std.fs.Dir,

    fn appendSection(assembler: *Assembler, offset: u16) !*Section {
        var node = try assembler.allocator.create(SectionNode);
        errdefer assembler.allocator.destroy(node);

        node.* = SectionNode{
            .data = Section{
                .offset = offset,
                .bytes = std.ArrayList(u8).init(assembler.allocator),
                .patches = std.ArrayList(Patch).init(assembler.allocator),
                .dot_offset = offset,
            },
        };

        assembler.sections.append(node);

        return &node.data;
    }

    fn currentSection(assembler: *Assembler) *Section {
        return &(assembler.sections.last orelse unreachable).data;
    }

    pub fn init(allocator: *std.mem.Allocator) !Assembler {
        var a = Self{
            .allocator = allocator,
            .sections = std.TailQueue(Section){},
            .symbols = std.StringHashMap(u16).init(allocator),
            .local_symbols = undefined,
            .errors = std.ArrayList(CompileError).init(allocator),
            .fileName = undefined,
            .directory = undefined,
            .string_arena = std.heap.ArenaAllocator.init(allocator),
            .interned_strings = .{},
        };
        errdefer a.string_arena.deinit();

        a.local_symbols = try a.string_arena.allocator.create(std.StringHashMap(u16));
        a.local_symbols.* = std.StringHashMap(u16).init(&a.string_arena.allocator);

        _ = try a.appendSection(0x0000);

        return a;
    }

    pub fn deinit(self: *Self) void {
        while (self.sections.pop()) |sect| {
            sect.data.deinit();
            self.allocator.destroy(sect);
        }
        self.interned_strings.deinit(self.allocator);
        self.string_arena.deinit();
        self.symbols.deinit();
        self.* = undefined;
    }

    pub fn finalize(self: *Self) !void {
        var iter = self.sections.first;
        while (iter) |section_node| : (iter = section_node.next) {
            const section = &section_node.data;

            for (section.patches.items) |patch| {
                self.local_symbols = patch.locals; // hacky

                const value = self.evaluate(patch.value, true) catch |err| switch (err) {
                    error.MissingIdentifiers => continue,
                    else => return err,
                };

                switch (value) {
                    .number => |n| std.mem.writeIntLittle(u16, section.bytes.items[patch.offset..][0..2], n),
                    else => return error.TypeMismatch,
                }
            }

            for (section.patches.items) |*patch| {
                patch.value.deinit();
            }
            section.patches.shrinkRetainingCapacity(0);
        }
    }

    fn emitError(self: *Self, kind: CompileError.Type, location: ?Location, comptime fmt: []const u8, args: anytype) !void {
        const msg = try std.fmt.allocPrint(self.allocator, fmt, args);
        errdefer self.allocator.free(msg);

        var location_clone = location;
        if (location_clone) |*l| {
            l.file = try self.internString(self.fileName);
        }

        try self.errors.append(CompileError{
            .location = location_clone,
            .type = kind,
            .message = msg,
        });
    }

    const AssembleError = std.fs.File.OpenError || std.fs.File.ReadError || std.fs.File.SeekError || EvaluationError || Parser.ParseError || error{
        UnexpectedEndOfFile,
        UnrecognizedCharacter,
        IncompleteStringLiteral,
        UnexpectedToken,
        OutOfMemory,
        UnknownMnemonic,
        UnexpectedOperand,
        DuplicateModifier,
        InvalidModifier,
        OutOfRange,
        UnknownDirective,
        DuplicateSymbol,
        EndOfStream,
        StreamTooLong,
        ParensImbalance,
    };
    pub fn assemble(self: *Assembler, fileName: []const u8, directory: ?std.fs.Dir, stream: anytype) AssembleError!void {
        var parser = try Parser.fromStream(self.allocator, stream);
        defer parser.deinit();

        self.fileName = fileName;
        self.directory = directory;

        while (true) {
            const token = try parser.peek();

            if (token == null) // end of file
                break;

            // Update the dot offset to the start of the next *thing*.
            self.currentSection().dot_offset = self.currentSection().getGlobalOffset();

            switch (token.?.type) {
                // process directive
                .dot_identifier => try parseDirective(self, &parser),

                // label,
                .label => {
                    const label = try parser.expect(.label);

                    const name = try self.internString(label.text[0 .. label.text.len - 1]);

                    const offset = self.currentSection().getGlobalOffset();

                    if (name[0] == '.') {
                        // local label
                        try self.local_symbols.put(name, offset);
                    } else {
                        // global label
                        self.local_symbols = try self.string_arena.allocator.create(std.StringHashMap(u16));
                        self.local_symbols.* = std.StringHashMap(u16).init(&self.string_arena.allocator);
                        try self.symbols.put(name, offset);
                    }
                },

                // modifier
                .identifier, .opening_brackets => try parseInstruction(self, &parser),

                // empty line, skip those
                .line_break => _ = try parser.expect(.line_break),

                else => return error.UnexpectedToken,
            }
        }

        self.fileName = undefined;
        self.directory = null;
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

        var instruction_token: ?Token = null;

        // parse modifiers and
        while (true) {
            var tok = try parser.expectAny(.{
                .identifier, // label or equ
                .opening_brackets, // modifier
            });
            switch (tok.type) {
                .identifier => {
                    instruction_token = tok;
                    break;
                },
                .opening_brackets => try modifiers.parse(assembler, parser),
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
                    try modifiers.parse(assembler, parser);
                },
                else => {
                    if (operand_count >= operands.len or end_of_operands) {
                        return error.UnexpectedOperand;
                    }
                    const expr_result = try parser.parseExpression(assembler.allocator, .{ .line_break, .comma, .opening_brackets });
                    operands[operand_count] = expr_result.expression;
                    operand_count += 1;
                    switch (expr_result.terminator.type) {
                        .line_break => break,
                        .opening_brackets => {
                            try modifiers.parse(assembler, parser);
                            end_of_operands = true;
                        },
                        .comma => {},
                        else => unreachable,
                    }
                },
            }
        }

        // search for instruction template
        var instruction = getInstructionForMnemonic(instruction_token.?.text, operand_count) orelse {
            return try assembler.emitError(.@"error", instruction_token.?.location, "Unknown mnemonic: {s}", .{instruction_token.?.text});
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

    fn parseDirective(assembler: *Self, parser: *Parser) !void {
        var token = try parser.expect(.dot_identifier);

        inline for (std.meta.declarations(Directives)) |decl| {
            if (decl.data != .Fn)
                continue;
            if (decl.name[0] != '.')
                continue;
            if (std.mem.eql(u8, decl.name, token.text)) {
                try @field(Directives, decl.name)(assembler, parser);
                return;
            }
        }

        if (std.builtin.mode == .Debug) {
            std.debug.warn("unknown directive: {s}\n", .{token.text});
        }

        return error.UnknownDirective;
    }

    // Directives:

    const Directives = struct {
        fn @".org"(assembler: *Assembler, parser: *Parser) !void {
            const offset_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const offset = try assembler.evaluate(offset_expr.expression, true);
            if (offset != .number) {
                return try assembler.emitError(.@"error", offset_expr.expression.location, "Type mismatch: Expected number, found {s}", .{@tagName(offset)});
            }

            const sect = if (assembler.currentSection().bytes.items.len == 0)
                assembler.currentSection()
            else
                try assembler.appendSection(offset.number);

            sect.offset = offset.number;
        }

        fn @".ascii"(assembler: *Assembler, parser: *Parser) !void {
            const string_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const string = try assembler.evaluate(string_expr.expression, true);
            if (string != .string)
                return error.TypeMismatch;

            try assembler.emit(string.string);
        }

        fn @".asciiz"(assembler: *Assembler, parser: *Parser) !void {
            const string_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const string = try assembler.evaluate(string_expr.expression, true);
            if (string != .string)
                return error.TypeMismatch;
            try assembler.emit(string.string);

            try assembler.emitU8(0x00); // null terminator
        }

        fn @".align"(assembler: *Assembler, parser: *Parser) !void {
            const alignment_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const alignment = try assembler.evaluate(alignment_expr.expression, true);
            if (alignment != .number)
                return error.TypeMismatch;

            const sect = assembler.currentSection();

            const newSize = std.mem.alignForward(sect.bytes.items.len, alignment.number);

            if (newSize != sect.bytes.items.len) {
                try sect.bytes.appendNTimes(0x00, newSize - sect.bytes.items.len);
            }

            std.debug.assert(sect.bytes.items.len == newSize);
        }

        fn @".space"(assembler: *Assembler, parser: *Parser) !void {
            const size_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const size = try assembler.evaluate(size_expr.expression, true);
            if (size != .number)
                return error.TypeMismatch;

            const sect = assembler.currentSection();

            try sect.bytes.appendNTimes(0x00, size.number);
        }

        fn @".dw"(assembler: *Assembler, parser: *Parser) !void {
            while (true) {
                const value_expr = try parser.parseExpression(assembler.allocator, .{ .line_break, .comma });

                try assembler.emitExpr(value_expr.expression);

                if (value_expr.terminator.type == .line_break)
                    break;
            }
        }

        fn @".db"(assembler: *Assembler, parser: *Parser) !void {
            while (true) {
                const value_expr = try parser.parseExpression(assembler.allocator, .{ .line_break, .comma });

                const value = try assembler.evaluate(value_expr.expression, true);
                if (value != .number)
                    return error.TypeMismatch;

                if (value.number >= 0x100)
                    return error.OutOfRange;

                try assembler.emitU8(@intCast(u8, value.number));

                if (value_expr.terminator.type == .line_break)
                    break;
            }
        }

        fn @".equ"(assembler: *Assembler, parser: *Parser) !void {
            const name_tok = try parser.expect(.identifier);

            _ = try parser.expect(.comma);

            const name = try assembler.internString(name_tok.text);

            const value_expr = try parser.parseExpression(assembler.allocator, .{.line_break});
            const value = try assembler.evaluate(value_expr.expression, true);
            if (value != .number)
                return error.TypeMismatch;

            // TODO: reinclude duplicatesymbol
            try assembler.symbols.put(name, value.number);
        }

        fn @".incbin"(assembler: *Assembler, parser: *Parser) !void {
            const filename_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const filename = try assembler.evaluate(filename_expr.expression, true);
            if (filename != .string)
                return error.TypeMismatch;

            if (assembler.directory) |dir| {
                var blob = try dir.readFileAlloc(assembler.allocator, filename.string, 65536);
                defer assembler.allocator.free(blob);

                try assembler.currentSection().bytes.writer().writeAll(blob);
            } else {
                try assembler.emitError(.@"error", filename_expr.expression.location, "Cannot open file {s}: No filesystem available", .{filename});
            }
        }

        fn @".include"(assembler: *Assembler, parser: *Parser) !void {
            const filename_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

            const filename = try assembler.evaluate(filename_expr.expression, true);
            if (filename != .string)
                return error.TypeMismatch;

            if (assembler.directory) |dir| {
                var file = try dir.openFile(filename.string, .{ .read = true, .write = false });
                defer file.close();

                const old_file_name = assembler.fileName;

                defer assembler.fileName = old_file_name;
                defer assembler.directory = dir;

                var new_dir = try dir.openDir(std.fs.path.dirname(filename.string) orelse ".", .{ .access_sub_paths = true, .iterate = false });
                defer new_dir.close();

                try assembler.assemble(filename.string, new_dir, file.reader());
            } else {
                try assembler.emitError(.@"error", filename_expr.expression.location, "Cannot open file {s}: No filesystem available", .{filename});
            }
        }
    };
    // Output handling:

    fn emit(assembler: *Assembler, bytes: []const u8) !void {
        const sect = assembler.currentSection();
        try sect.bytes.writer().writeAll(bytes);
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

        if (assembler.evaluate(copy, false)) |value| {
            if (value != .number) {
                if (std.builtin.mode == .Debug) {
                    std.debug.warn("unexpected value: {}\n", .{value});
                }
                return error.TypeMismatch;
            }
            try assembler.emitU16(value.number);
            copy.deinit();
        } else |err| switch (err) {
            error.MissingIdentifiers => {
                const sect = assembler.currentSection();
                const ptr = sect.getLocalOffset();

                // Defer evaluation to end of assembling,
                // store label context (for locals) and expr for later, write dummy value
                try assembler.emitU16(0x5555);

                try sect.patches.append(Patch{
                    .offset = ptr,
                    .value = copy,
                    .locals = assembler.local_symbols,
                });
            },
            else => return err,
        }
    }

    // Expression handling

    fn parseAndInternString(assembler: *Assembler, token: Token) ![]const u8 {
        const buffer = try assembler.allocator.alloc(u8, token.text.len - 2);
        defer assembler.allocator.free(buffer);

        var length: usize = 0;

        var offset: usize = 1;
        while (offset < token.text.len - 1) {
            const c = try translateEscapedChar(token.text[offset..]);

            buffer[length] = c.char;
            length += 1;
            offset += c.length;
        }

        return try assembler.internString(buffer[0..length]);
    }

    fn internString(assembler: *Assembler, string: []const u8) ![]const u8 {
        const gop = try assembler.interned_strings.getOrPut(assembler.allocator, string);
        if (!gop.found_existing) {
            gop.key_ptr.* = try assembler.string_arena.allocator.dupe(u8, string);
        }
        return gop.key_ptr.*;
    }

    const EvaluationError = error{ InvalidExpression, UnknownFunction, MissingIdentifiers, OutOfMemory, TypeMismatch, Overflow, InvalidCharacter };
    fn evaluate(assembler: *Assembler, expression: Expression, emitErrorOnMissing: bool) EvaluationError!Value {
        return try expression.evaluate(assembler, emitErrorOnMissing);

        //         .operator_plus => {
        //             const rhs = stack.popOrNull() orelse return error.InvalidExpression;
        //             const lhs = stack.popOrNull() orelse return error.InvalidExpression;

        //             if (@as(ValueType, lhs) != @as(ValueType, rhs))
        //                 return error.TypeMismatch;
        //             try stack.append(switch (lhs) {
        //                 .number => Value{ .number = lhs.number +% rhs.number },
        //                 .string => Value{
        //                     .string = try std.mem.concat(assembler.allocator, u8, &[_][]const u8{
        //                         lhs.string,
        //                         rhs.string,
        //                     }),
        //                 },
        //             });
        //         },
        //     }
        // }

    }

    const EscapingResult = struct {
        char: u8,
        length: usize,
    };
    fn translateEscapedChar(pattern: []const u8) !EscapingResult {
        if (pattern[0] != '\\')
            return EscapingResult{ .char = pattern[0], .length = 1 };

        return EscapingResult{
            .length = 2,
            .char = switch (pattern[1]) {
                'a' => 0x07,
                'b' => 0x08,
                'e' => 0x1B,
                'n' => 0x0A,
                'r' => 0x0D,
                't' => 0x0B,
                '\\' => 0x5C,
                '\'' => 0x27,
                '\"' => 0x22,
                'x' => {
                    return EscapingResult{
                        .length = 4,
                        .char = try std.fmt.parseInt(u8, pattern[2..4], 16),
                    };
                },
                else => |c| c,
            },
        };
    }
};

pub const TokenType = enum {
    const Self = @This();

    whitespace,
    comment, // ; …
    line_break, // "\n"

    identifier, // fooas2_3
    dot_identifier, // .fooas2_3
    label, //foobar:, .foobar:
    function, // #symbol

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

    fn isOperator(self: Self) bool {
        return switch (self) {
            .operator_plus, .operator_minus, .operator_multiply, .operator_divide, .operator_modulo, .operator_bitand, .operator_bitor, .operator_bitxor, .operator_shl, .operator_shr, .operator_asr, .operator_bitnot => true,
            else => false,
        };
    }
};

pub const Location = struct {
    file: ?[]const u8,
    line: u32,
    column: u32,

    fn merge(a: Location, b: Location) Location {
        std.debug.assert(std.meta.eql(a.file, b.file));
        return if (a.line < b.line)
            a
        else if (a.line > b.line)
            b
        else if (a.column < b.column)
            a
        else
            b;
    }
};

pub const Token = struct {
    const Self = @This();

    text: []const u8,
    type: TokenType,
    location: Location,

    fn duplicate(self: Self, allocator: *std.mem.Allocator) !Self {
        return Self{
            .type = self.type,
            .text = try std.mem.dupe(allocator, u8, self.text),
            .location = self.location,
        };
    }
};

pub const Parser = struct {
    allocator: ?*std.mem.Allocator,
    source: []u8,
    offset: usize,
    peeked_token: ?Token,
    current_location: Location,

    const Self = @This();

    fn fromStream(allocator: *std.mem.Allocator, stream: anytype) !Self {
        return Self{
            .allocator = allocator,
            .source = try stream.readAllAlloc(allocator, 16 << 20), // 16 MB
            .offset = 0,
            .peeked_token = null,
            .current_location = Location{
                .line = 1,
                .column = 1,
                .file = null,
            },
        };
    }

    fn fromSlice(text: []const u8) Self {
        return Self{
            .allocator = null,
            .source = text,
            .offset = 0,
            .peeked_token = null,
            .current_location = Location{
                .line = 1,
                .column = 1,
                .file = null,
            },
        };
    }

    fn deinit(self: *Self) void {
        if (self.allocator) |a|
            a.free(self.source);
        self.* = undefined;
    }

    fn expect(parser: *Self, t: TokenType) !Token {
        var state = parser.saveState();
        errdefer parser.restoreState(state);

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

    fn expectAny(parser: *Self, types: anytype) !Token {
        var state = parser.saveState();
        errdefer parser.restoreState(state);

        const tok = (try parser.parse()) orelse return error.UnexpectedEndOfFile;
        inline for (types) |t| {
            if (tok.type == @as(TokenType, t))
                return tok;
        }
        // if (std.builtin.mode == .Debug) {
        //     std.debug.warn("Unexpected token: {}\nexpected one of: {}\n", .{
        //         tok,
        //         types,
        //     });
        // }
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
            .location = parser.current_location,
        };
    }

    fn isWordCharacter(c: u8) bool {
        return switch (c) {
            'a'...'z' => true,
            'A'...'Z' => true,
            '0'...'9' => true,
            '_' => true,
            '.' => true,
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

        // Return a .line_break when we reached the end of the file
        // Prevents a whole class of errors in the rest of the code :)
        if (parser.offset == parser.source.len) {
            parser.offset += 1;
            return Token{
                .text = "\n",
                .type = .line_break,
                .location = parser.current_location,
            };
        } else if (parser.offset >= parser.source.len) {
            return null;
        }
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
                    .location = parser.current_location,
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
                        .location = parser.current_location,
                    };
                } else {
                    break :blk Token{
                        .type = .dot_identifier,
                        .text = parser.source[parser.offset..off],
                        .location = parser.current_location,
                    };
                }
            },

            // operator_shr, // >>
            // operator_asr, // >>>
            '>' => blk: {
                if (parser.offset + 1 >= parser.source.len)
                    return error.UnexpectedEndOfFile;
                if (parser.source[parser.offset + 1] != '>')
                    return error.UnrecognizedCharacter;

                if (parser.offset + 2 < parser.source.len and parser.source[parser.offset + 2] == '>') {
                    break :blk Token{
                        .type = .operator_asr,
                        .text = parser.source[parser.offset..][0..3],
                        .location = parser.current_location,
                    };
                } else {
                    break :blk Token{
                        .type = .operator_shr,
                        .text = parser.source[parser.offset..][0..2],
                        .location = parser.current_location,
                    };
                }
            },

            '<' => blk: {
                if (parser.offset + 1 >= parser.source.len)
                    return error.UnexpectedEndOfFile;
                if (parser.source[parser.offset + 1] != '<')
                    return error.UnrecognizedCharacter;
                break :blk Token{
                    .type = .operator_shl,
                    .text = parser.source[parser.offset..][0..2],
                    .location = parser.current_location,
                };
            },

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
                                .location = parser.current_location,
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
                                .location = parser.current_location,
                            };
                        },
                        else => break :blk Token{
                            .type = .dec_number,
                            .text = parser.source[parser.offset .. parser.offset + 1],
                            .location = parser.current_location,
                        },
                    }
                } else {
                    break :blk Token{
                        .type = .dec_number,
                        .text = parser.source[parser.offset .. parser.offset + 1],
                        .location = parser.current_location,
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
                        .location = parser.current_location,
                    };
                } else {
                    break :blk Token{
                        .type = .identifier,
                        .text = parser.source[parser.offset..off],
                        .location = parser.current_location,
                    };
                }
            },

            // string_literal, char_literal
            '\'', '\"' => blk: {
                var off = parser.offset + 1;
                if (off == parser.source.len)
                    return error.IncompleteStringLiteral;

                const delimiter = parser.source[parser.offset];

                while (parser.source[off] != delimiter) {
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
                    .type = if (delimiter == '\'')
                        .char_literal
                    else
                        .string_literal,
                    .text = parser.source[parser.offset..off],
                    .location = parser.current_location,
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

        for (token.text) |c| {
            if (c == '\n') {
                parser.current_location.line += 1;
                parser.current_location.column = 1;
            } else {
                parser.current_location.column += 1;
            }
        }

        return token;
    }

    fn lastOfSlice(slice: anytype) @TypeOf(slice[0]) {
        return slice[slice.len - 1];
    }

    const ParserState = struct {
        source: []u8,
        offset: usize,
        peeked_token: ?Token,
        current_location: Location,
    };

    fn saveState(parser: Parser) ParserState {
        return ParserState{
            .source = parser.source,
            .offset = parser.offset,
            .peeked_token = parser.peeked_token,
            .current_location = parser.current_location,
        };
    }

    fn restoreState(parser: *Parser, state: ParserState) void {
        parser.source = state.source;
        parser.offset = state.offset;
        parser.peeked_token = state.peeked_token;
        parser.current_location = state.current_location;
    }

    // parses an expression from the token stream
    const ParseExpressionResult = struct {
        expression: Expression,
        terminator: Token,
    };
    fn parseExpression(parser: *Parser, allocator: *std.mem.Allocator, terminators: anytype) !ParseExpressionResult {
        _ = terminators;

        const state = parser.saveState();
        errdefer parser.restoreState(state);

        var expr = Expression{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .root = undefined,
            .location = undefined,
        };
        errdefer expr.arena.deinit();

        expr.root = try parser.acceptExpression(&expr.arena.allocator);

        return ParseExpressionResult{
            .expression = expr,
            .terminator = try parser.expectAny(terminators),
        };
    }

    fn moveToHeap(allocator: *std.mem.Allocator, value: anytype) !*@TypeOf(value) {
        const T = @TypeOf(value);
        std.debug.assert(@typeInfo(T) != .Pointer);
        const ptr = try allocator.create(T);
        ptr.* = value;
        std.debug.assert(std.meta.eql(ptr.*, value));
        return ptr;
    }

    const ParseError = error{
        OutOfMemory,
        UnexpectedEndOfFile,
        UnrecognizedCharacter,
        IncompleteStringLiteral,
        UnexpectedToken,
        InvalidNumber,
        InvalidCharacter,
    };
    const acceptExpression = acceptSumExpression;

    fn acceptSumExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        var expr = try self.acceptMulExpression(allocator);
        while (true) {
            var and_or = self.expectAny(.{
                .operator_plus,
                .operator_minus,
            }) catch break;
            var rhs = try self.acceptMulExpression(allocator);

            var new_expr = ExpressionNode{
                .location = expr.location.merge(and_or.location).merge(rhs.location),
                .type = .{
                    .binary_op = .{
                        .operator = switch (and_or.type) {
                            .operator_plus => .add,
                            .operator_minus => .sub,
                            else => unreachable,
                        },
                        .lhs = try moveToHeap(allocator, expr),
                        .rhs = try moveToHeap(allocator, rhs),
                    },
                },
            };
            expr = new_expr;
        }
        return expr;
    }

    fn acceptMulExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        var expr = try self.acceptBitwiseExpression(allocator);
        while (true) {
            var and_or = self.expectAny(.{
                .operator_multiply,
                .operator_divide,
                .operator_modulo,
            }) catch break;
            var rhs = try self.acceptBitwiseExpression(allocator);

            var new_expr = ExpressionNode{
                .location = expr.location.merge(and_or.location).merge(rhs.location),
                .type = .{
                    .binary_op = .{
                        .operator = switch (and_or.type) {
                            .operator_multiply => .mul,
                            .operator_divide => .div,
                            .operator_modulo => .mod,
                            else => unreachable,
                        },
                        .lhs = try moveToHeap(allocator, expr),
                        .rhs = try moveToHeap(allocator, rhs),
                    },
                },
            };
            expr = new_expr;
        }
        return expr;
    }

    fn acceptBitwiseExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        var expr = try self.acceptShiftExpression(allocator);
        while (true) {
            var and_or = self.expectAny(.{
                .operator_bitand,
                .operator_bitor,
                .operator_bitxor,
            }) catch break;
            var rhs = try self.acceptShiftExpression(allocator);

            var new_expr = ExpressionNode{
                .location = expr.location.merge(and_or.location).merge(rhs.location),
                .type = .{
                    .binary_op = .{
                        .operator = switch (and_or.type) {
                            .operator_bitand => .bit_and,
                            .operator_bitor => .bit_or,
                            .operator_bitxor => .bit_xor,
                            else => unreachable,
                        },
                        .lhs = try moveToHeap(allocator, expr),
                        .rhs = try moveToHeap(allocator, rhs),
                    },
                },
            };
            expr = new_expr;
        }
        return expr;
    }

    fn acceptShiftExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        var expr = try self.acceptUnaryPrefixOperatorExpression(allocator);
        while (true) {
            var and_or = self.expectAny(.{
                .operator_shl,
                .operator_shr,
                .operator_asr,
            }) catch break;
            var rhs = try self.acceptUnaryPrefixOperatorExpression(allocator);

            var new_expr = ExpressionNode{
                .location = expr.location.merge(and_or.location).merge(rhs.location),
                .type = .{
                    .binary_op = .{
                        .operator = switch (and_or.type) {
                            .operator_shl => .lsl,
                            .operator_shr => .lsr,
                            .operator_asr => .asr,
                            else => unreachable,
                        },
                        .lhs = try moveToHeap(allocator, expr),
                        .rhs = try moveToHeap(allocator, rhs),
                    },
                },
            };
            expr = new_expr;
        }
        return expr;
    }

    fn acceptUnaryPrefixOperatorExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        if (self.expectAny(.{ .operator_bitnot, .operator_minus })) |prefix| {
            // this must directly recurse as we can write `not not x`
            const value = try self.acceptUnaryPrefixOperatorExpression(allocator);
            return ExpressionNode{
                .location = prefix.location.merge(value.location),
                .type = .{
                    .unary_op = .{
                        .operator = switch (prefix.type) {
                            .operator_bitnot => .bit_invert,
                            .operator_minus => .negate,
                            else => unreachable,
                        },
                        .value = try moveToHeap(allocator, value),
                    },
                },
            };
        } else |_| {
            return try self.acceptCallExpression(allocator);
        }
    }

    const acceptCallExpression = acceptValueExpression;
    // fn acceptCallExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
    //     const state = self.saveState();
    //     errdefer self.restoreState(state);

    //     var value = try self.acceptValueExpression(allocator);

    //     while (self.expect(.opening_parens)) |_| {
    //         var args = std.ArrayList(ExpressionNode).init(allocator);
    //         defer args.deinit();

    //         var loc = value.location;

    //         if (self.expect(.closing_parens)) |_| {
    //             // this is the end of the argument list
    //         } else |_| {
    //             while (true) {
    //                 const arg = try self.acceptExpression(allocator);
    //                 try args.append(arg);
    //                 const terminator = try self.expectAny(.{ .closing_parens, .comma });
    //                 loc = terminator.location.merge(loc);
    //                 if (terminator.type == .closing_parens)
    //                     break;
    //             }
    //         }

    //         const old_val = value;
    //         value = ExpressionNode{
    //             .location = loc,
    //             .type = .{
    //                 .fn_call = .{
    //                     .function = try moveToHeap(allocator, old_val),
    //                     .arguments = args.toOwnedSlice(),
    //                 },
    //             },
    //         };
    //     } else |_| {}

    //     return value;
    // }

    fn acceptValueExpression(self: *Parser, allocator: *std.mem.Allocator) ParseError!ExpressionNode {
        const state = self.saveState();
        errdefer self.restoreState(state);

        const token = try self.expectAny(.{
            .opening_parens,
            .bin_number,
            .oct_number,
            .dec_number,
            .hex_number,
            .string_literal,
            .char_literal,
            .identifier,
        });
        switch (token.type) {
            .opening_parens => {
                const value = try self.acceptExpression(allocator);
                _ = try self.expect(.closing_parens);
                return value;
            },
            .bin_number => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .numeric_literal = std.fmt.parseInt(i64, token.text[2..], 2) catch return error.InvalidNumber,
                },
            },
            .oct_number => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .numeric_literal = std.fmt.parseInt(i64, token.text[2..], 8) catch return error.InvalidNumber,
                },
            },
            .dec_number => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .numeric_literal = std.fmt.parseInt(i64, token.text, 10) catch return error.InvalidNumber,
                },
            },
            .hex_number => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .numeric_literal = std.fmt.parseInt(i64, token.text[2..], 16) catch return error.InvalidNumber,
                },
            },

            .string_literal => {
                std.debug.assert(token.text.len >= 2);
                return ExpressionNode{
                    .location = token.location,
                    .type = .{
                        .string_literal = token.text[1 .. token.text.len - 1],
                    },
                };
            },

            .char_literal => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .numeric_literal = (Assembler.translateEscapedChar(token.text[1..]) catch return error.InvalidCharacter).char,
                },
            },

            .identifier => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .symbol_reference = try allocator.dupe(u8, token.text),
                },
            },

            .dot_identifier => return ExpressionNode{
                .location = token.location,
                .type = .{
                    .local_symbol_reference = try allocator.dupe(u8, token.text),
                },
            },
            else => unreachable,
        }
    }
};

const ExpressionNode = struct {
    location: Location,
    type: ExpressionType,
    const ExpressionType = union(enum) {
        const Self = @This();

        string_literal: []const u8,
        numeric_literal: i64,
        symbol_reference: []const u8,
        local_symbol_reference: []const u8,
        current_location,

        binary_op: BinaryExpr,
        unary_op: UnaryExpr,

        fn_call: FunctionCall,

        const BinaryExpr = struct {
            operator: BinaryOperator,
            lhs: *ExpressionNode,
            rhs: *ExpressionNode,
        };

        const UnaryExpr = struct {
            operator: UnaryOperator,
            value: *ExpressionNode,
        };

        const FunctionCall = struct {
            function: []const u8,
            arguments: []Self,
        };

        const BinaryOperator = enum {
            add,
            sub,
            mul,
            div,
            mod,
            bit_and,
            bit_or,
            bit_xor,
            lsl,
            lsr,
            asr,
        };
        const UnaryOperator = enum {
            negate,
            bit_invert,
        };
    };
};

const Value = union(enum) {
    string: []const u8, // does not need to be freed, will be string-pooled
    number: u16,
};
const ValueType = std.meta.Tag(Value);

/// A sequence of tokens created with a shunting yard algorithm.
/// Can be parsed/executed left-to-right
const Expression = struct {
    const Self = @This();

    arena: std.heap.ArenaAllocator,
    location: Location,
    root: ExpressionNode,

    fn deinit(expr: *Expression) void {
        expr.arena.deinit();
        expr.* = undefined;
    }

    pub const EvalError = error{ MissingIdentifiers, UnknownFunction, OutOfMemory, TypeMismatch, Overflow };
    pub fn evaluate(self: *const Self, context: *Assembler, emitErrorOnMissing: bool) EvalError!Value {
        const errors = ErrorEmitter{
            .context = context,
            .emitErrorOnMissing = emitErrorOnMissing,
        };
        const result = try self.evaluateRecursive(context, errors, &self.root);
        return switch (result) {
            .number => |v| Value{ .number = try errors.truncateTo(v) },
            .string => |s| Value{ .string = s },
        };
    }

    const ErrorEmitter = struct {
        context: *Assembler,
        emitErrorOnMissing: bool,

        pub fn emit(self: @This(), err: EvalError, location: ?Location, comptime fmt: []const u8, args: anytype) EvalError {
            if (self.emitErrorOnMissing) {
                try self.context.emitError(.@"error", location, fmt, args);
            }
            return err;
        }

        fn requireValueType(errors: ErrorEmitter, comptime valtype: std.meta.Tag(EvalValue), value: EvalValue) !switch (valtype) {
            .number => i64,
            .string => []const u8,
        } {
            return switch (value) {
                valtype => |v| v,
                else => errors.emit(error.TypeMismatch, null, "Expected {s}, got {s}", .{ std.meta.tagName(valtype), std.meta.tagName(value) }),
            };
        }

        fn requireNumber(errors: ErrorEmitter, value: EvalValue) !i64 {
            return requireValueType(errors, .number, value);
        }

        fn requireString(errors: ErrorEmitter, value: EvalValue) ![]const u8 {
            return requireValueType(errors, .string, value);
        }

        fn truncateTo(errors: ErrorEmitter, src: i64) !u16 {
            const result = @truncate(u16, @bitCast(u64, src));
            if (src < 0 or src > 0xFFFF) {
                if (errors.emitErrorOnMissing) {
                    try errors.context.emitError(.warning, null, "Truncating numeric {} to 16-bit value {}", .{ src, result });
                }
            }
            return result;
        }
    };

    const EvalValue = union(enum) {
        string: []const u8, // does not need to be freed, will be string-pooled
        number: i64,
    };

    fn evaluateRecursive(self: *const Self, context: *Assembler, errors: ErrorEmitter, node: *const ExpressionNode) EvalError!EvalValue {
        return switch (node.type) {
            .numeric_literal => |number| EvalValue{ .number = number },
            .string_literal => |str| EvalValue{
                .string = try context.internString(str),
            },
            .current_location => EvalValue{
                .number = @intCast(u16, context.currentSection().getDotOffset()),
            },

            .symbol_reference => |symbol_name| if (context.symbols.get(symbol_name)) |sym|
                EvalValue{ .number = sym }
            else
                return errors.emit(error.MissingIdentifiers, null, "Missing identifier: {s}", .{symbol_name}),

            .local_symbol_reference => |symbol_name| if (context.local_symbols.get(symbol_name)) |sym|
                EvalValue{ .number = sym }
            else
                return errors.emit(error.MissingIdentifiers, null, "Missing identifier: {s}", .{symbol_name}),

            .binary_op => |op| blk: {
                const lhs = try self.evaluateRecursive(context, errors, op.lhs);
                const rhs = try self.evaluateRecursive(context, errors, op.rhs);
                break :blk switch (op.operator) {
                    .add => EvalValue{
                        .number = (try errors.requireNumber(lhs)) +% (try errors.requireNumber(rhs)),
                    },
                    .sub => EvalValue{
                        .number = (try errors.requireNumber(lhs)) -% (try errors.requireNumber(rhs)),
                    },
                    .mul => EvalValue{
                        .number = (try errors.requireNumber(lhs)) *% (try errors.requireNumber(rhs)),
                    },
                    .div => EvalValue{
                        .number = @divTrunc(try errors.requireNumber(lhs), try errors.requireNumber(rhs)),
                    },
                    .mod => EvalValue{
                        .number = @mod(try errors.requireNumber(lhs), try errors.requireNumber(rhs)),
                    },
                    .bit_and => EvalValue{
                        .number = (try errors.requireNumber(lhs)) & (try errors.requireNumber(rhs)),
                    },
                    .bit_or => EvalValue{
                        .number = (try errors.requireNumber(lhs)) | (try errors.requireNumber(rhs)),
                    },
                    .bit_xor => EvalValue{
                        .number = (try errors.requireNumber(lhs)) ^ (try errors.requireNumber(rhs)),
                    },
                    .lsl => EvalValue{
                        .number = @truncate(u16, @bitCast(u64, try errors.requireNumber(lhs))) << @truncate(u4, @bitCast(u64, try errors.requireNumber(rhs))),
                    },
                    .lsr => EvalValue{
                        .number = @truncate(u16, @bitCast(u64, try errors.requireNumber(lhs))) >> @truncate(u4, @bitCast(u64, try errors.requireNumber(rhs))),
                    },
                    .asr => asr_res: {
                        const lhs_n = try errors.truncateTo(try errors.requireNumber(lhs));
                        const rhs_n = try errors.truncateTo(try errors.requireNumber(rhs));
                        const bits = @truncate(u4, rhs_n);
                        const shifted = (lhs_n >> bits);

                        if (lhs_n >= 0x8000) {
                            const mask_mask: u16 = @as(u16, 0xFFFF) >> bits;
                            const mask: u16 = @as(u16, 0xFFFF) & ~mask_mask;
                            break :asr_res EvalValue{
                                .number = shifted | mask,
                            };
                        }
                        break :asr_res EvalValue{
                            .number = shifted,
                        };

                        // } else {
                        //     break :asr_res (lhs_n >> bits);
                        // }

                    },
                };
            },
            .unary_op => |op| blk: {
                const value = try errors.requireNumber(try self.evaluateRecursive(context, errors, op.value));
                break :blk switch (op.operator) {
                    .bit_invert => EvalValue{
                        .number = ~value,
                    },
                    .negate => EvalValue{
                        .number = 0 -% value,
                    },
                };
            },
            .fn_call => |fun| {
                std.log.err("TODO: Implement function evaluation!", .{});
                return errors.emit(error.UnknownFunction, null, "The function {s} does not exist!", .{fun});
            },
        };
    }

    pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
        _ = fmt;
        _ = options;
        for (value.sequence) |item, i| {
            if (i > 0)
                try stream.writeAll(" ");
            try stream.writeAll(item.text);
        }
    }
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
    fn parse(mods: *Self, assembler: *Assembler, parser: *Parser) !void {
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
                    mods.input1 = item[1];
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
        try assembler.emitError(.@"error", mod_type.location, "Unknown modifier: {s}{s}", .{ mod_type.text, mod_value.text });
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
    };

    const command_items = .{
        .{ "copy", .copy },
        .{ "get", .get },
        .{ "set", .set },
        .{ "store8", .store8 },
        .{ "store16", .store16 },
        .{ "load8", .load8 },
        .{ "load16", .load16 },
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
        .{ "setip", .setip },
        .{ "addip", .addip },
        .{ "intr", .intr },
    };
};

test "empty file" {
    var as = try Assembler.init(std.testing.allocator);
    defer as.deinit();

    var stream = std.io.fixedBufferStream(
        \\
    );

    try as.assemble("memory", null, stream.reader());
    try as.finalize();

    try std.testing.expectEqual(@as(usize, 0), as.errors.items.len);
    try std.testing.expect(as.sections.first != null);

    try std.testing.expectEqual(@as(usize, 0), as.sections.first.?.data.offset);
    try std.testing.expectEqual(@as(usize, 0), as.sections.first.?.data.bytes.items.len);
}

test "section deduplication" {
    var as = try Assembler.init(std.testing.allocator);
    defer as.deinit();

    var stream = std.io.fixedBufferStream(
        \\.org 0x8000
    );

    try as.assemble("memory", null, stream.reader());
    try as.finalize();

    try std.testing.expectEqual(@as(usize, 0), as.errors.items.len);
    try std.testing.expect(as.sections.first != null);

    try std.testing.expectEqual(@as(usize, 0x8000), as.sections.first.?.data.offset);
    try std.testing.expectEqual(@as(usize, 0), as.sections.first.?.data.bytes.items.len);
}

test "emit raw word" {
    var as = try Assembler.init(std.testing.allocator);
    defer as.deinit();

    var stream = std.io.fixedBufferStream(
        \\.dw 0x1234
        \\.dw 0x5678, 0x9ABC
    );

    try as.assemble("memory", null, stream.reader());
    try as.finalize();

    try std.testing.expectEqual(@as(usize, 0), as.errors.items.len);
    try std.testing.expect(as.sections.first != null);

    const sect = as.sections.first.?.data;

    try std.testing.expectEqual(@as(usize, 0x0000), sect.offset);
    try std.testing.expectEqual(@as(usize, 6), sect.bytes.items.len);
    try std.testing.expectEqual(@as(u16, 0x1234), std.mem.readIntLittle(u16, sect.bytes.items[0..2]));
    try std.testing.expectEqual(@as(u16, 0x5678), std.mem.readIntLittle(u16, sect.bytes.items[2..4]));
    try std.testing.expectEqual(@as(u16, 0x9ABC), std.mem.readIntLittle(u16, sect.bytes.items[4..6]));
}

test "emit raw byte" {
    var as = try Assembler.init(std.testing.allocator);
    defer as.deinit();

    var stream = std.io.fixedBufferStream(
        \\.db 0x12
        \\.db 0x34, 0x56, 0x78
    );

    try as.assemble("memory", null, stream.reader());
    try as.finalize();

    try std.testing.expectEqual(@as(usize, 0), as.errors.items.len);
    try std.testing.expect(as.sections.first != null);

    const sect = as.sections.first.?.data;

    try std.testing.expectEqual(@as(usize, 0x0000), sect.offset);
    try std.testing.expectEqual(@as(usize, 4), sect.bytes.items.len);
    try std.testing.expectEqual(@as(u8, 0x12), std.mem.readIntLittle(u8, sect.bytes.items[0..1]));
    try std.testing.expectEqual(@as(u8, 0x34), std.mem.readIntLittle(u8, sect.bytes.items[1..2]));
    try std.testing.expectEqual(@as(u8, 0x56), std.mem.readIntLittle(u8, sect.bytes.items[2..3]));
    try std.testing.expectEqual(@as(u8, 0x78), std.mem.readIntLittle(u8, sect.bytes.items[3..4]));
}

fn testExpressionEvaluation(expected: u16, comptime source: []const u8) !void {
    var as = try Assembler.init(std.testing.allocator);
    defer as.deinit();

    {
        var source_cpy = source[0..source.len].*;
        var stream = std.io.fixedBufferStream(source);

        try as.assemble("memory", null, stream.reader());

        // destroy all evidence
        std.mem.set(u8, &source_cpy, 0x55);

        try as.finalize();
    }

    try std.testing.expectEqual(@as(usize, 0), as.errors.items.len);
    try std.testing.expect(as.sections.first != null);

    const sect = as.sections.first.?.data;

    try std.testing.expectEqual(@as(usize, 0x0000), sect.offset);
    try std.testing.expectEqual(@as(usize, 2), sect.bytes.items.len);
    try std.testing.expectEqual(expected, std.mem.readIntLittle(u16, sect.bytes.items[0..2]));
}

test "parsing integer literals" {
    try testExpressionEvaluation(100,
        \\.dw 100 ; decimal
    );
    try testExpressionEvaluation(0b100,
        \\.dw 0b100 ; binary
    );
    try testExpressionEvaluation(0o100,
        \\.dw 0o100 ; octal
    );
    try testExpressionEvaluation(0x100,
        \\.dw 0x100 ; hexadecimal
    );
}

test "basic (non-nested) basic arithmetic" {
    try testExpressionEvaluation(30,
        \\.dw 20+10
    );
    try testExpressionEvaluation(10,
        \\.dw 20-10
    );
    try testExpressionEvaluation(200,
        \\.dw 20*10
    );
    try testExpressionEvaluation(2,
        \\.dw 20/10
    );
}

test "basic (non-nested) bitwise arithmetic" {
    try testExpressionEvaluation(3,
        \\.dw 7&3
    );
    try testExpressionEvaluation(12,
        \\.dw 8|12
    );
    try testExpressionEvaluation(4,
        \\.dw 13^9
    );
}

test "basic (non-nested) shift arithmetic" {
    try testExpressionEvaluation(256,
        \\.dw 16<<4
    );
    try testExpressionEvaluation(4,
        \\.dw 16>>2
    );
    try testExpressionEvaluation(0xFFFF,
        \\.dw 0x8000>>>15
    );
    try testExpressionEvaluation(0x0000,
        \\.dw 0x7FFF>>>15
    );
}

test "basic unary operators" {
    try testExpressionEvaluation(0x00FF,
        \\.dw ~0xFF00
    );
    try testExpressionEvaluation(65526,
        \\.dw -10
    );
}

test "operator precedence" {
    try testExpressionEvaluation(610,
        \\.dw 10+20*30
    );
    try testExpressionEvaluation(900,
        \\.dw (10+20)*30
    );
}

test "backward references" {
    try testExpressionEvaluation(0,
        \\backward:
        \\.dw backward
    );
}

test "forward references" {
    try testExpressionEvaluation(2,
        \\.dw forward
        \\forward:
    );
}
