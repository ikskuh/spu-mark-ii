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

        try assembler.assemble(path, dir, file.inStream());
    }

    // std.debug.warn("assembler output:\n", .{});
    // {
    //     var iter = assembler.sections.first;
    //     while (iter) |section_node| : (iter = section_node.next) {
    //         const section = &section_node.data;

    //         std.debug.warn(
    //             \\  section:
    //             \\    offset: {X:0>4}
    //             \\    length: {X:0>4}
    //             \\    data:   {X}
    //             \\    patches:
    //             \\
    //         , .{
    //             section.offset,
    //             section.bytes.items.len,
    //             section.bytes.items,
    //         });

    //         for (section.patches.items) |patch| {
    //             std.debug.warn("      - {X:0>4} → \"{}\"\n", .{
    //                 patch.offset,
    //                 patch.value,
    //             });
    //         }
    //     }
    // }
    // {
    //     std.debug.warn("  symbols:\n", .{});
    //     var iter = assembler.symbols.iterator();
    //     while (iter.next()) |sym| {
    //         std.debug.warn("    `{}` → {X:0>4}\n", .{
    //             sym.key,
    //             sym.value,
    //         });
    //     }
    // }

    try assembler.finalize();

    {
        var file = try root_dir.createFile(cli_args.options.output, .{ .truncate = true, .exclusive = false });
        defer file.close();

        var outstream = file.outStream();

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
                    ":{X}\n",
                    .{buffer[0 .. length + 5]},
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
};

pub const Section = struct {
    const Self = @This();

    offset: u16,
    bytes: std.ArrayList(u8),
    patches: std.ArrayList(Patch),

    fn deinit(self: *Self) void {
        self.bytes.deinit();
        self.patches.deinit();
        self.* = undefined;
    }

    fn getLocalOffset(sect: Self) u16 {
        return @intCast(u16, sect.bytes.items.len);
    }

    fn getGlobalOffset(sect: Self) u16 {
        return @intCast(u16, sect.offset + sect.bytes.items.len);
    }
};

pub const Assembler = struct {
    const Self = @This();
    const SectionNode = std.TailQueue(Section).Node;

    // utilities
    allocator: *std.mem.Allocator,

    // assembling result
    sections: std.TailQueue(Section),
    symbols: std.StringHashMap(u16),
    local_symbols: std.StringHashMap(u16),

    // in-flight symbols
    fileName: []const u8,
    directory: std.fs.Dir,

    fn appendSection(assembler: *Assembler, offset: u16) !*Section {
        var node = try assembler.allocator.create(SectionNode);
        errdefer assembler.allocator.destroy(node);

        node.* = SectionNode.init(Section{
            .offset = offset,
            .bytes = std.ArrayList(u8).init(assembler.allocator),
            .patches = std.ArrayList(Patch).init(assembler.allocator),
        });

        assembler.sections.append(node);

        return &node.data;
    }

    fn currentSection(assembler: *Assembler) *Section {
        return &(assembler.sections.last orelse unreachable).data;
    }

    pub fn init(allocator: *std.mem.Allocator) !Assembler {
        var a = Self{
            .allocator = allocator,
            .sections = std.TailQueue(Section).init(),
            .symbols = std.StringHashMap(u16).init(allocator),
            .local_symbols = std.StringHashMap(u16).init(allocator),
            .fileName = undefined,
            .directory = undefined,
        };

        _ = try a.appendSection(0x0000);

        return a;
    }

    pub fn deinit(self: *Self) void {
        while (self.sections.pop()) |sect| {
            sect.data.deinit();
            self.allocator.destroy(sect);
        }
        self.* = undefined;
    }

    pub fn finalize(self: *Self) !void {
        var iter = self.sections.first;
        while (iter) |section_node| : (iter = section_node.next) {
            const section = &section_node.data;

            for (section.patches.items) |patch| {
                const value = try self.evaluate(patch.value);

                switch (value) {
                    .number => |n| std.mem.writeIntLittle(u16, section.bytes.items[patch.offset..][0..2], n),
                    else => return error.TypeMismatch,
                }
            }

            section.patches.shrink(0);
        }
    }

    const AssembleError = std.fs.File.OpenError || std.fs.File.ReadError || std.fs.File.SeekError || EvaluationError || error{
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
    pub fn assemble(self: *Assembler, fileName: []const u8, directory: std.fs.Dir, stream: var) AssembleError!void {
        var parser = try Parser.fromStream(self.allocator, stream);
        defer parser.deinit();

        self.fileName = fileName;
        self.directory = directory;

        while (true) {
            const token = try parser.peek();

            if (token == null) // end of file
                break;

            switch (token.?.type) {
                // process directive
                .dot_identifier => try parseDirective(self, &parser),

                // label,
                .label => {
                    const label = try parser.expect(.label);

                    const name = try std.mem.dupe(self.allocator, u8, label.text[0 .. label.text.len - 1]);

                    const offset = self.currentSection().getGlobalOffset();

                    if (name[0] == '.') {
                        // local label
                        if (try self.local_symbols.put(name, offset)) |kv| {
                            return error.DuplicateSymbol;
                        }
                    } else {
                        // global label
                        self.local_symbols.clear();
                        if (try self.symbols.put(name, offset)) |kv| {
                            return error.DuplicateSymbol;
                        }
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
        self.directory = undefined;
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
                    const expr_result = try parser.parseExpression(assembler.allocator, .{ .line_break, .comma, .opening_brackets });
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
        const offset_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const offset = try assembler.evaluate(offset_expr.expression);
        if (offset != .number)
            return error.TypeMismatch;

        const sect = if (assembler.currentSection().bytes.items.len == 0)
            assembler.currentSection()
        else
            try assembler.appendSection(offset.number);

        sect.offset = offset.number;
    }

    fn @".ascii"(assembler: *Assembler, parser: *Parser) !void {
        const string_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const string = try assembler.evaluate(string_expr.expression);
        if (string != .string)
            return error.TypeMismatch;

        try assembler.emit(string.string);
    }

    fn @".asciiz"(assembler: *Assembler, parser: *Parser) !void {
        const string_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const string = try assembler.evaluate(string_expr.expression);
        if (string != .string)
            return error.TypeMismatch;
        try assembler.emit(string.string);

        try assembler.emitU8(0x00); // null terminator
    }

    fn @".align"(assembler: *Assembler, parser: *Parser) !void {
        const alignment_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const alignment = try assembler.evaluate(alignment_expr.expression);
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

        const size = try assembler.evaluate(size_expr.expression);
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

            const value = try assembler.evaluate(value_expr.expression);
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

        const name = try std.mem.dupe(assembler.allocator, u8, name_tok.text);
        errdefer assembler.allocator.free(name);

        const value_expr = try parser.parseExpression(assembler.allocator, .{.line_break});
        const value = try assembler.evaluate(value_expr.expression);
        if (value != .number)
            return error.TypeMismatch;

        if (try assembler.symbols.put(name, value.number)) |kv| {
            return error.DuplicateSymbol;
        }
    }

    fn @".incbin"(assembler: *Assembler, parser: *Parser) !void {
        const filename_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const filename = try assembler.evaluate(filename_expr.expression);
        if (filename != .string)
            return error.TypeMismatch;

        var blob = try assembler.directory.readFileAlloc(assembler.allocator, filename.string, 65536);
        defer assembler.allocator.free(blob);

        try assembler.currentSection().bytes.outStream().writeAll(blob);
    }

    fn @".include"(assembler: *Assembler, parser: *Parser) !void {
        const filename_expr = try parser.parseExpression(assembler.allocator, .{.line_break});

        const filename = try assembler.evaluate(filename_expr.expression);
        if (filename != .string)
            return error.TypeMismatch;

        var file = try assembler.directory.openFile(filename.string, .{ .read = true, .write = false });
        defer file.close();

        const old_file_name = assembler.fileName;
        const old_directory = assembler.directory;

        defer assembler.fileName = old_file_name;
        defer assembler.directory = old_directory;

        var dir = try assembler.directory.openDir(std.fs.path.dirname(filename.string) orelse ".", .{ .access_sub_paths = true, .iterate = false });
        defer dir.close();

        try assembler.assemble(filename.string, dir, file.inStream());
    }

    // Output handling:

    fn emit(assembler: *Assembler, bytes: []const u8) !void {
        const sect = assembler.currentSection();
        try sect.bytes.outStream().writeAll(bytes);
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
                });
            },
            else => return err,
        }
    }

    // Expression handling

    fn parseAndInternString(assembler: *Assembler, token: Token) ![]const u8 {
        // very interning, much optimization
        // TODO: Implement actual string interning
        const buffer = try assembler.allocator.alloc(u8, token.text.len - 2);
        errdefer assembler.allocator.free(buffer);

        const State = enum {
            normal,
            escape,
        };

        var length: usize = 0;
        var state: State = .normal;

        var offset: usize = 1;
        while (offset < token.text.len - 1) {
            const c = try translateEscapedChar(token.text[offset..]);

            buffer[length] = c.char;
            length += 1;
            offset += c.length;
        }

        return buffer[0..length];
    }

    const EvaluationError = error{ InvalidExpression, MissingIdentifiers, OutOfMemory, TypeMismatch, Overflow, InvalidCharacter };
    fn evaluate(assembler: *Assembler, expression: Expression) EvaluationError!Value {
        var stack = std.ArrayList(Value).init(assembler.allocator);
        defer stack.deinit();

        std.debug.warn("evaluate expression: `{}`", .{expression});

        for (expression.sequence) |item| {
            switch (item.type) {
                .identifier => if (assembler.symbols.get(item.text)) |sym|
                    try stack.append(Value{ .number = sym.value })
                else {
                    if (std.builtin.mode == .Debug) {
                        std.debug.warn("missing identifier: `{}`\n", .{item.text});
                    }
                    return error.MissingIdentifiers;
                },

                .dot_identifier => if (assembler.local_symbols.get(item.text)) |sym|
                    try stack.append(Value{ .number = sym.value })
                else {
                    if (std.builtin.mode == .Debug) {
                        std.debug.warn("missing local identifier: `{}`\n", .{item.text});
                    }
                    return error.MissingIdentifiers;
                },

                // Number literals
                .bin_number => try stack.append(Value{
                    .number = try std.fmt.parseInt(u16, item.text[2..], 2),
                }),
                .oct_number => try stack.append(Value{
                    .number = try std.fmt.parseInt(u16, item.text[2..], 8),
                }),
                .dec_number => try stack.append(Value{
                    .number = try std.fmt.parseInt(u16, item.text, 10),
                }),
                .hex_number => try stack.append(Value{
                    .number = try std.fmt.parseInt(u16, item.text[2..], 16),
                }),
                .char_literal => {
                    try stack.append(Value{
                        .number = (try translateEscapedChar(item.text[1..])).char,
                    });
                },
                .dot => try stack.append(Value{
                    .number = @intCast(u16, assembler.currentSection().getGlobalOffset()),
                }),

                // String literal
                .string_literal => try stack.append(Value{
                    .string = try assembler.parseAndInternString(item),
                }),

                // This is advanced stuff for later!

                .operator_plus => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (@as(ValueType, lhs) != @as(ValueType, rhs))
                        return error.TypeMismatch;
                    try stack.append(switch (lhs) {
                        .number => Value{ .number = lhs.number +% rhs.number },
                        .string => Value{
                            .string = try std.mem.concat(assembler.allocator, u8, &[_][]const u8{
                                lhs.string,
                                rhs.string,
                            }),
                        },
                    });
                },
                .operator_minus => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number -% rhs.number });
                },
                .operator_multiply => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number *% rhs.number });
                },
                .operator_divide => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number / rhs.number });
                },
                .operator_modulo => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number % rhs.number });
                },
                .operator_bitand => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number & rhs.number });
                },
                .operator_bitor => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number | rhs.number });
                },
                .operator_bitxor => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = lhs.number ^ rhs.number });
                },
                .operator_shl => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = @truncate(u16, lhs.number << @truncate(u4, rhs.number)) });
                },
                .operator_shr => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = @truncate(u16, lhs.number >> @truncate(u4, rhs.number)) });
                },
                .operator_asr => {
                    const rhs = stack.popOrNull() orelse return error.InvalidExpression;
                    const lhs = stack.popOrNull() orelse return error.InvalidExpression;

                    if (lhs != .number or rhs != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = (lhs.number & 0x8000) | (lhs.number >> @truncate(u4, rhs.number)) });
                },
                .operator_bitnot => {
                    const value = stack.popOrNull() orelse return error.InvalidExpression;

                    if (value != .number)
                        return error.TypeMismatch;
                    try stack.append(Value{ .number = ~value.number });
                },

                // If it's none of the above tokens, we made a programming mistake earlier
                else => unreachable,
            }
        }

        if (stack.items.len != 1)
            return error.InvalidExpression;

        std.debug.warn(" => `{}`\n", .{
            stack.items[0],
        });

        return stack.items[0];
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

    const Value = union(enum) {
        string: []const u8, // does not need to be freed, will be string-pooled
        number: u16,
    };
    const ValueType = @TagType(Value);
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

    fn operatorPrecedence(self: Self) u32 {
        return switch (self) {
            .operator_plus => 10,
            .operator_minus => 10,
            .operator_multiply => 20,
            .operator_divide => 20,
            .operator_modulo => 20,
            .operator_bitand => 30,
            .operator_bitor => 30,
            .operator_bitxor => 30,
            .operator_shl => 40,
            .operator_shr => 40,
            .operator_asr => 40,
            .operator_bitnot => 50,
            else => unreachable, // programming mistake
        };
    }
};

pub const Token = struct {
    const Self = @This();

    text: []const u8,
    type: TokenType,

    fn duplicate(self: Self, allocator: *std.mem.Allocator) !Self {
        return Self{
            .type = self.type,
            .text = try std.mem.dupe(allocator, u8, self.text),
        };
    }
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

    fn lastOfSlice(slice: var) @TypeOf(slice[0]) {
        return slice[slice.len - 1];
    }

    // parses an expression from the token stream
    const ParseExpressionResult = struct {
        expression: Expression,
        terminator: Token,
    };
    fn parseExpression(parser: *Parser, allocator: *std.mem.Allocator, terminators: var) !ParseExpressionResult {
        var stack = std.ArrayList(Token).init(allocator);
        defer stack.deinit();

        var sequence = std.ArrayList(Token).init(allocator);
        errdefer sequence.deinit();

        const terminator = input_loop: while (true) {
            var tok = try parser.expectAny(.{
                // literals and identifiers
                .dec_number,
                .hex_number,
                .oct_number,
                .bin_number,
                .dot,
                .identifier,
                .char_literal,
                .string_literal,

                // operators
                .operator_plus,
                .operator_minus,
                .operator_multiply,
                .operator_divide,
                .operator_modulo,
                .operator_bitand,
                .operator_bitor,
                .operator_bitxor,
                .operator_shl,
                .operator_shr,
                .operator_asr,
                .operator_bitnot,
            } ++ terminators);

            inline for (terminators) |t| {
                if (tok.type == t)
                    break :input_loop tok;
            }
            switch (tok.type) {
                .dec_number, .hex_number, .oct_number, .bin_number, .dot, .identifier, .char_literal, .string_literal => {
                    try sequence.append(tok);
                },

                .function => {
                    try stack.append(tok);
                },

                .comma => {
                    while (lastOfSlice(stack.items).type != .opening_parens) {
                        try sequence.append(stack.pop());
                        if (stack.items.len == 0)
                            return error.UnexpectedToken;
                        //         FEHLER-BEI Stack IST-LEER:
                        //             GRUND (1) Ein falsch platziertes Argumenttrennzeichen.
                        //             GRUND (2) Der schließenden Klammer geht keine öffnende voraus.
                        //         ENDEFEHLER
                    }
                },

                .operator_plus, .operator_minus, .operator_multiply, .operator_divide, .operator_modulo, .operator_bitand, .operator_bitor, .operator_bitxor, .operator_shl, .operator_shr, .operator_asr, .operator_bitnot => {
                    while (stack.items.len != 0 and lastOfSlice(stack.items).type.isOperator() and tok.type.operatorPrecedence() <= lastOfSlice(stack.items).type.operatorPrecedence()) {
                        try sequence.append(stack.pop());
                    }
                    try stack.append(tok);
                },

                .opening_parens => {
                    try stack.append(tok);
                },

                .closing_parens => {

                    // BIS Stack-Spitze IST öffnende-Klammer:
                    //     FEHLER-BEI Stack IST-LEER:
                    //         GRUND (1) Der schließenden Klammer geht keine öffnende voraus.
                    //     ENDEFEHLER
                    //     Stack-Spitze ZU Ausgabe.
                    // ENDEBIS
                    // Stack-Spitze (öffnende-Klammer) entfernen
                    // WENN Stack-Spitze IST-Funktion:
                    //     Stack-Spitze ZU Ausgabe.
                    // ENDEWENN
                },

                else => {
                    if (std.builtin.mode == .Debug) {
                        std.debug.warn("unreachable token in parseExpression: {}\n", .{tok});
                    }
                    unreachable;
                },
            }
        } else unreachable;

        while (stack.items.len > 0) {
            const tok = stack.pop();
            if (tok.type == .opening_parens)
                return error.ParensImbalance;
            try sequence.append(tok);
        }

        for (sequence.items) |*item| {
            item.* = try item.duplicate(allocator);
        }

        return ParseExpressionResult{
            .expression = Expression{
                .allocator = allocator,
                .sequence = sequence.toOwnedSlice(),
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

    pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: var) !void {
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
