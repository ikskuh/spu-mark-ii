const std = @import("std");
const argsParser = @import("args");

pub fn main() anyerror!u8 {
    const cli_args = argsParser.parseForCurrentProcess(struct {
        // This declares long options for double hyphen
        output: ?[]const u8 = null,
        help: bool = false,

        // This declares short-hand options for single hyphen
        pub const shorthands = .{
            .o = "output",
            .h = "help",
        };
    }, std.heap.page_allocator, .print) catch return 1;
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len != 1 or cli_args.options.output == null) {
        try std.io.getStdOut().writeAll(
            \\ make-vhd [-h] [-o outfile] infile.bin
            \\ -h, --help    Outputs this help text
            \\ -o, --output  Defines the name of the output file, required
            \\
            \\ Converts a binary blob into a VHDL lookup table for easier
            \\ inclusion in synthesis over different projects.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else 1; // when we explicitly call help, we succeed
    }

    const infile = try std.fs.cwd().openFile(cli_args.positionals[0], .{ .read = true, .write = false });
    defer infile.close();

    const outfile = try std.fs.cwd().createFile(cli_args.options.output.?, .{ .exclusive = false, .read = false });
    defer outfile.close();

    var istream = infile.reader();
    var ostream = outfile.writer();

    try ostream.writeAll(
        \\LIBRARY IEEE;
        \\USE IEEE.std_logic_1164.ALL;
        \\USE IEEE.numeric_std.ALL;
        \\
        \\package generated is
        \\
        \\  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector;
        \\
        \\end package;
        \\
        \\package body generated is
        \\
        \\  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector is
        \\  begin
        \\    case to_integer(unsigned(addr & "0")) is
        \\
    );

    var addr: u16 = 0;
    while (true) {
        var bits: [2]u8 = undefined;
        istream.readNoEof(&bits) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        // HACK: If address is not in RAM, emit it into VHDL
        if (addr < 0x8000) {
            const word = @bitCast(u16, bits);
            if (word != 0) {
                try ostream.print("      when 16#{X:0>4}# => return \"{b:0>16}\";\n", .{ addr, word });
            }
        }
        addr += 2;
    }

    try ostream.writeAll("      when others   => return \"0000000000000000\";\n");
    try ostream.writeAll(
        \\    end case;
        \\  end function;
        \\
        \\end package body;
        \\
    );

    return 0;
}
