const std = @import("std");
const pcx = @import("pcx.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("castle.pcx", .{ .read = true, .write = false });
    defer file.close();

    var img = try pcx.load(std.heap.page_allocator, &file);
    defer img.deinit();

    std.debug.assert(img == .bpp8);

    var out = try std.fs.cwd().createFile("castle.bit", .{ .truncate = true });
    defer out.close();

    var ostream = out.outStream();

    std.debug.warn("{}×{}\n", .{
        img.bpp8.width,
        img.bpp8.height,
    });

    var y: usize = 0;
    while (y < 128) : (y += 1) {
        var x: usize = 0;
        while (x < 256) : (x += 1) {
            try ostream.writeIntLittle(u8, 'B');
            try ostream.writeIntLittle(u24, 0x810000 | @intCast(u24, y << 8) | @intCast(u24, x));
            try ostream.writeIntLittle(u8, img.bpp8.pixels[y * img.bpp8.width + x]);
        }
    }
}
