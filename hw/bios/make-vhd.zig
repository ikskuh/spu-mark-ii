const std = @import("std");

pub fn main() anyerror!u8 {
    if (std.os.argv.len != 3) {
        std.debug.warn("Expects 2 args, found {}!\n", .{std.os.argv.len});
    }
    const infile = try std.fs.cwd().openFile(std.mem.spanZ(std.os.argv[2]), .{ .read = true, .write = false });
    defer infile.close();

    const outfile = try std.fs.cwd().createFile(std.mem.spanZ(std.os.argv[1]), .{ .exclusive = false, .read = false });
    defer outfile.close();

    var istream = infile.inStream();
    var ostream = outfile.outStream();

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

        // HACK: If address is in RAM, emit it into VHDL
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
