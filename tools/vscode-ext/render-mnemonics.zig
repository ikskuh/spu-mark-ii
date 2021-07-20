const std = @import("std");

const mnemonics = @import("../assembler/mnemonics.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var items = mnemonics.mnemonics;

    std.sort.sort(mnemonics.Mnemonic, &items, {}, lt);

    try stdout.writeAll("module.exports = [\n");
    for (items) |m| {
        try stdout.print("  {{ name: '{s}', desc: \"{}\", argc: {}, input0: '{s}', input1: '{s}', output: '{s}', command: '{s}', flags: {}, condition: '{s}' }},\n", .{
            m.name,
            std.zig.fmtEscapes(m.info),
            m.argc,
            @tagName(m.instruction.input0),
            @tagName(m.instruction.input1),
            @tagName(m.instruction.output),
            @tagName(m.instruction.command),
            m.instruction.modify_flags,
            @tagName(m.instruction.condition),
        });
    }
    try stdout.writeAll("];\n");
}

fn lt(_: void, a: mnemonics.Mnemonic, b: mnemonics.Mnemonic) bool {
    if (std.mem.lessThan(u8, a.name, b.name))
        return true;
    if (a.argc < b.argc)
        return true;
    return false;
}
