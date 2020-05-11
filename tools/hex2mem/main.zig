const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");

extern fn configure_serial(fd: c_int) u8;

extern fn flush_serial(fd: c_int) void;

pub fn main() anyerror!u8 {
    const cli_args = try argsParser.parseForCurrentProcess(struct {
        // This declares long options for double hyphen
        output: ?[]const u8 = null,
        help: bool = false,
        size: ?usize = null,

        // This declares short-hand options for single hyphen
        pub const shorthands = .{
            .o = "output",
            .h = "help",
            .s = "size",
        };
    }, std.heap.page_allocator);
    defer cli_args.deinit();

    const stdout = std.io.getStdOut().outStream();
    const stdin = std.io.getStdOut().inStream();

    if (cli_args.options.help or cli_args.positionals.len == 0 or cli_args.options.output == null) {
        try stdout.writeAll(
            \\ hex2mem [-h] [-o outfile] infile.hex [infile.hex …]
            \\ -h, --help    Outputs this help text
            \\ -o, --output  Defines the name of the output file, required
            \\ -s, --size    If given, the file will have this size in bytes,
            \\               otherwise the size will be determined automatically.
            \\
            \\ Combines one or more intel hex files into a lattice memory file.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else 1; // when we explicitly call help, we succeed
    }

    const outfile = try std.fs.cwd().createFile(cli_args.options.output.?, .{ .truncate = true, .read = true });
    defer outfile.close();

    const MemPrinter = struct {
        const Self = @This();
        const Error = error{InvalidHexFile} || std.os.WriteError || std.os.SeekError;

        file: *const std.fs.File,

        fn load(p: *const Self, base: u32, data: []const u8) Error!void {
            const out = p.file.outStream();

            try out.print("{X} :", .{@divExact(base, 2)});

            for (std.mem.bytesAsSlice(u16, data)) |b| {
                try out.print(" {X:0>4}", .{b});
            }

            try out.writeAll("\n");
        }
    };

    const parseMode = ihex.ParseMode{
        .pedantic = true,
    };

    const loader = MemPrinter{
        .file = &outfile,
    };

    for (cli_args.positionals) |file_name| {
        var infile = try std.fs.cwd().openFile(file_name, .{ .read = true, .write = false });
        defer infile.close();

        _ = try ihex.parseData(infile.inStream(), parseMode, &loader, MemPrinter.Error, MemPrinter.load);
    }

    return 0;
}
