const std = @import("std");
const pcx = @import("pcx.zig");
const argsParser = @import("args");

pub fn main() !u8 {
    const cli_args = argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        output: ?[]const u8 = null,

        pub const shorthands = .{
            .h = "help",
            .o = "output",
        };
    }, std.heap.page_allocator, .print) catch return 1;
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len != 1) {
        try std.io.getStdOut().writer().writeAll(
            \\bit-converter --help [--output file] pcx-file
            \\Converts a PCX file into a bit-bang sequence for the 
            \\
            \\-h, --help     Displays this help text.
            \\-o, --output   Defines the name of the output file. If not given,
            \\               the bit-converter will write the bit sequence to stdout.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else @as(u8, 1);
    }

    var file = try std.fs.cwd().openFile(cli_args.positionals[0], .{ .read = true, .write = false });
    defer file.close();

    var img = try pcx.load(std.heap.page_allocator, &file);
    defer img.deinit();

    if (img != .bpp8) {
        try std.io.getStdErr().writer().print("The provided file is not a file with 8 bit per pixel, but uses the format {}!\n", .{
            @as(pcx.Format, img),
        });
        return 1;
    }

    var out = if (cli_args.options.output) |outfile|
        try std.fs.cwd().createFile(outfile, .{ .truncate = true })
    else
        std.io.getStdOut();

    defer if (cli_args.options.output) |_|
        out.close();

    var ostream = out.writer();

    var y: usize = 0;
    while (y < 128) : (y += 1) {
        var x: usize = 0;
        while (x < 256) : (x += 1) {
            try ostream.writeIntLittle(u8, 'B');
            try ostream.writeIntLittle(u24, 0x810000 | @intCast(u24, y << 8) | @intCast(u24, x));
            try ostream.writeIntLittle(u8, img.bpp8.pixels[y * img.bpp8.width + x]);
        }
    }

    return 0;
}
