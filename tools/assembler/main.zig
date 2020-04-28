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

    pub fn assemble(assembler: *Assembler, fileName: []const u8, stream: var) !void {
        var parser = Parser{};

        _ = try parser.parse(stream);
    }
};

pub const TokenType = enum {
    whitespace,
    comment, // ; …
    line_break, // "\n"

    identifier, // fooas2_3
    dot_identifier, // .fooas2_3

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
    const Self = @This();

    fn parse(parser: *Self, stream: var) !Token {
        while (true) {
            var token = try parser.parseRaw(stream);
            if (token) |tok| {
                switch (tok.type) {
                    .whitespace => continue,
                    else => return tok,
                }
            }
            return error.EndOfStream;
        }
    }

    fn parseRaw(parser: *Self, stream: var) !?Token {
        var start = try stream.readByte();
        switch (start) {
            else => return error.UnrecognizedCharacter,
        }
    }
};
