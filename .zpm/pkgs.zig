const std = @import("std");

fn pkgRoot() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub const pkgs = struct {
    pub const ihex = std.build.Pkg{
        .name = "ihex",
        .path = .{ .path = pkgRoot() ++ "/../.zpm/../tools/modules/zig-ihex/ihex.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
    pub const serial = std.build.Pkg{
        .name = "serial",
        .path = .{ .path = pkgRoot() ++ "/../.zpm/../tools/modules/zig-serial/serial.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
    pub const @"spu-mk2" = std.build.Pkg{
        .name = "spu-mk2",
        .path = .{ .path = pkgRoot() ++ "/../.zpm/../tools/common/spu-mk2.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
    pub const sdl2 = std.build.Pkg{
        .name = "sdl2",
        .path = .{ .path = pkgRoot() ++ "/../.zpm/../tools/modules/SDL.zig/src/lib.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
    pub const args = std.build.Pkg{
        .name = "args",
        .path = .{ .path = pkgRoot() ++ "/../tools/modules/zig-args/args.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
};

pub const imports = struct {
};
