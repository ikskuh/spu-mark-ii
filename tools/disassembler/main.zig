const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");

usingnamespace @import("spu-mk2");

const FileFormat = enum { ihex, binary };
const DisasmError = error{EndOfStream} || std.os.WriteError || std.io.FixedBufferStream([]const u8).ReadError;

fn processRecord(out: *const std.io.OutStream(std.fs.File, std.os.WriteError, std.fs.File.write), base: u32, data: []const u8) DisasmError!void {
    const in = std.io.fixedBufferStream(data).inStream();

    var offset = base;

    while (true) {
        try out.print("{X:0>4} ", .{offset});
        offset += 2;

        if (in.readIntLittle(u16)) |instr_int| {
            const instr = @bitCast(Instruction, instr_int);

            try out.print("{}", .{instr});

            if (instr.input0 == .immediate) {
                offset += 2;
                const val = in.readIntLittle(u16) catch |err| switch (err) {
                    error.EndOfStream => {
                        try out.writeAll(" | ????\n");
                        return;
                    },
                    else => return err,
                };
                try out.print(" | {X:0>4}", .{val});
            }

            if (instr.input1 == .immediate) {
                offset += 2;
                const val = in.readIntLittle(u16) catch |err| switch (err) {
                    error.EndOfStream => {
                        try out.writeAll(" | ????\n");
                        return;
                    },
                    else => return err,
                };
                try out.print(" | {X:0>4}", .{val});
            }

            try out.writeAll("\n");
        } else |err| {
            switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        }
    }
}

pub fn main() !u8 {
    const cli_args = try argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        format: ?FileFormat = null,
        offset: ?u16 = null,

        pub const shorthands = .{
            .h = "help",
            .f = "format",
        };
    }, std.heap.page_allocator);
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len == 0) {
        try std.io.getStdOut().outStream().writeAll(
            \\disassembler --help [--format ihex|binary] [--offset XXXX] fileA fileB
            \\Disassembles code for the SPU Mark II platform.
            \\
            \\-h, --help     Displays this help text.
            \\-f, --format   Selects the input format (binary or ihex).
            \\               If not given, the file extension will be used
            \\               to guess the format.
            \\--offset XXXX  Defines the disassembly offset for binary files.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else @as(u8, 1);
    }

    const out = std.io.getStdOut().outStream();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const hexParseMode = ihex.ParseMode{ .pedantic = true };
    for (cli_args.positionals) |path| {
        var file = try std.fs.cwd().openFile(path, .{ .read = true, .write = false });
        defer file.close();
        if (std.mem.endsWith(u8, path, ".hex")) {
            // Emulator will always start at address 0x0000 or CLI given entry point.
            _ = try ihex.parseData(&file.inStream(), hexParseMode, &out, DisasmError, processRecord);
        } else {
            const buffer = try file.inStream().readAllAlloc(&arena.allocator, 65536);
            defer arena.allocator.free(buffer);

            try processRecord(&out, cli_args.options.offset orelse 0x0000, buffer);
        }
    }

    return 0;
}
