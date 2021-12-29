const std = @import("std");

/// rgb color tuple with 8 bit color values.
pub const RGB = packed struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Header = packed struct {
    id: u8 = 0x0A,
    version: u8,
    compression: u8,
    bpp: u8,
    xmin: u16,
    ymin: u16,
    xmax: u16,
    ymax: u16,
    horizontalDPI: u16,
    verticalDPI: u16,
    builtinPalette: [16 * 3]u8,
    _reserved0: u8 = 0,
    planes: u8,
    stride: u16,
    paletteInformation: u16,
    screenWidth: u16,
    screenHeight: u16,

    var padding: [54]u8 = undefined;

    comptime {
        std.debug.assert(@sizeOf(@This()) == 74);
    }
};

fn SubImage(comptime Pixel: type) type {
    return struct {
        const Self = @This();

        const PaletteType = switch (Pixel) {
            u1 => [2]RGB,
            u4 => [16]RGB,
            u8 => [256]RGB,
            RGB => void,
            else => @compileError(@typeName(Pixel) ++ " not supported yet!"),
        };

        allocator: std.mem.Allocator,
        pixels: []Pixel,
        width: usize,
        height: usize,
        palette: ?*PaletteType,

        pub fn initLinear(allocator: std.mem.Allocator, header: Header, file: *std.fs.File, stream: anytype) !Self {
            const width = @as(usize, header.xmax - header.xmin + 1);
            const height = @as(usize, header.ymax - header.ymin + 1);

            var img = Self{
                .allocator = allocator,
                .pixels = try allocator.alloc(Pixel, width * height),
                .width = width,
                .height = height,
                .palette = null,
            };
            errdefer img.deinit();

            var decoder = RLEDecoder.init(stream);

            var y: usize = 0;
            while (y < img.height) : (y += 1) {
                var offset: usize = 0;
                var x: usize = 0;

                // read all pixels from the current row
                while (offset < header.stride and x < img.width) : (offset += 1) {
                    const byte = try decoder.readByte();
                    switch (Pixel) {
                        u1 => {},
                        u4 => {
                            img.pixels[y * img.width + x + 0] = @truncate(u4, byte);
                            x += 1;
                            if (x < img.width - 1) {
                                img.pixels[y * img.width + x + 1] = @truncate(u4, byte >> 4);
                                x += 1;
                            }
                        },
                        u8 => {
                            img.pixels[y * img.width + x] = byte;
                            x += 1;
                        },
                        RGB => {},
                        else => @compileError(@typeName(Pixel) ++ " not supported yet!"),
                    }
                }

                // discard the rest of the bytes in the current row
                while (offset < header.stride) : (offset += 1) {
                    _ = try decoder.readByte();
                }
            }

            try decoder.finish();

            if (Pixel != RGB) {
                var pal = try allocator.create(PaletteType);
                errdefer allocator.destroy(pal);

                var i: usize = 0;
                while (i < std.math.min(pal.len, header.builtinPalette.len / 3)) : (i += 1) {
                    pal[i].r = header.builtinPalette[3 * i + 0];
                    pal[i].g = header.builtinPalette[3 * i + 1];
                    pal[i].b = header.builtinPalette[3 * i + 2];
                }

                if (Pixel == u8) {
                    try file.seekFromEnd(-769);

                    if ((try stream.readByte()) != 0x0C)
                        return error.MissingPalette;

                    for (pal) |*c| {
                        c.r = try stream.readByte();
                        c.g = try stream.readByte();
                        c.b = try stream.readByte();
                    }
                }

                img.palette = pal;
            }

            return img;
        }

        pub fn deinit(self: Self) void {
            if (self.palette) |pal| {
                self.allocator.destroy(pal);
            }
            self.allocator.free(self.pixels);
        }
    };
}

pub const Format = enum {
    bpp1,
    bpp4,
    bpp8,
    bpp24,
};

pub const Image = union(Format) {
    bpp1: SubImage(u1),
    bpp4: SubImage(u4),
    bpp8: SubImage(u8),
    bpp24: SubImage(RGB),

    pub fn deinit(image: Image) void {
        switch (image) {
            .bpp1 => |img| img.deinit(),
            .bpp4 => |img| img.deinit(),
            .bpp8 => |img| img.deinit(),
            .bpp24 => |img| img.deinit(),
        }
    }
};

pub fn load(allocator: std.mem.Allocator, file: *std.fs.File) !Image {
    var stream = file.reader();

    var header: Header = undefined;
    try stream.readNoEof(std.mem.asBytes(&header));
    try stream.readNoEof(&Header.padding);

    if (header.id != 0x0A)
        return error.InvalidFileFormat;

    if (header.planes != 1)
        return error.UnsupportedFormat;

    var img: Image = undefined;
    switch (header.bpp) {
        1 => img = Image{
            .bpp1 = try SubImage(u1).initLinear(allocator, header, file, stream),
        },
        4 => img = Image{
            .bpp4 = try SubImage(u4).initLinear(allocator, header, file, stream),
        },
        8 => img = Image{
            .bpp8 = try SubImage(u8).initLinear(allocator, header, file, stream),
        },
        24 => img = Image{
            .bpp24 = try SubImage(RGB).initLinear(allocator, header, file, stream),
        },
        else => return error.UnsupportedFormat,
    }
    return img;
}

const RLEDecoder = struct {
    const Run = struct {
        value: u8,
        remaining: usize,
    };

    stream: std.fs.File.Reader,
    currentRun: ?Run,

    fn init(stream: std.fs.File.Reader) RLEDecoder {
        return RLEDecoder{
            .stream = stream,
            .currentRun = null,
        };
    }

    fn readByte(self: *RLEDecoder) !u8 {
        if (self.currentRun) |*run| {
            var result = run.value;
            run.remaining -= 1;
            if (run.remaining == 0)
                self.currentRun = null;
            return result;
        } else {
            while (true) {
                var byte = try self.stream.readByte();
                if (byte == 0xC0) // skip over "zero length runs"
                    continue;
                if ((byte & 0xC0) == 0xC0) {
                    const len = byte & 0x3F;
                    std.debug.assert(len > 0);
                    const result = try self.stream.readByte();
                    if (len > 1) {
                        // we only need to store a run in the decoder if it is longer than 1
                        self.currentRun = .{
                            .value = result,
                            .remaining = len - 1,
                        };
                    }
                    return result;
                } else {
                    return byte;
                }
            }
        }
    }

    fn finish(decoder: RLEDecoder) !void {
        if (decoder.currentRun != null)
            return error.RLEStreamIncomplete;
    }
};

test "PCX bpp1 (linear)" {
    var file = try std.fs.cwd().openRead("test/test-bpp1.pcx");
    defer file.close();

    var img = try load(std.debug.global_allocator, &file);
    errdefer img.deinit();

    std.debug.assert(img == .bpp1);
    std.debug.assert(img.bpp1.width == 27);
    std.debug.assert(img.bpp1.height == 27);
    std.debug.assert(img.bpp1.palette != null);
    std.debug.assert(img.bpp1.palette.?.len == 2);
}

test "PCX bpp4 (linear)" {
    var file = try std.fs.cwd().openRead("test/test-bpp4.pcx");
    defer file.close();

    var img = try load(std.debug.global_allocator, &file);
    errdefer img.deinit();

    std.debug.assert(img == .bpp4);
    std.debug.assert(img.bpp4.width == 27);
    std.debug.assert(img.bpp4.height == 27);
    std.debug.assert(img.bpp4.palette != null);
    std.debug.assert(img.bpp4.palette.?.len == 16);
}

test "PCX bpp8 (linear)" {
    var file = try std.fs.cwd().openRead("test/test-bpp8.pcx");
    defer file.close();

    var img = try load(std.debug.global_allocator, &file);
    errdefer img.deinit();

    std.debug.assert(img == .bpp8);
    std.debug.assert(img.bpp8.width == 27);
    std.debug.assert(img.bpp8.height == 27);
    std.debug.assert(img.bpp8.palette != null);
    std.debug.assert(img.bpp8.palette.?.len == 256);
}

// TODO: reimplement as soon as planar mode is implemented
// test "PCX bpp24 (planar)" {
//     var file = try std.fs.cwd().openRead("test/test-bpp24.pcx");
//     defer file.close();

//     var img = try load(std.debug.global_allocator, &file);
//     errdefer img.deinit();

//     std.debug.assert(img == .bpp24);
//     std.debug.assert(img.bpp24.width == 27);
//     std.debug.assert(img.bpp24.height == 27);
//     std.debug.assert(img.bpp24.palette == null);
// }
