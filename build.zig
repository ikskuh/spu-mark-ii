const std = @import("std");

const packages = struct {
    const args = std.build.Pkg{
        .name = "args",
        .path = "./tools/modules/zig-args/args.zig",
    };
    const ihex = std.build.Pkg{
        .name = "ihex",
        .path = "./tools/modules/zig-ihex/ihex.zig",
    };
    const serial = std.build.Pkg{
        .name = "serial",
        .path = "./tools/modules/zig-serial/serial.zig",
    };
    const spumk2 = std.build.Pkg{
        .name = "spu-mk2",
        .path = "./tools/common/spu-mk2.zig",
    };
};

const examples = [_][]const u8{
    "apps/hello-world/main",
    "apps/ascii-printer/main",
};

const Toolchain = struct {
    debugger: *std.build.LibExeObjStep,
    emulator: *std.build.LibExeObjStep,
    disassembler: *std.build.LibExeObjStep,
    assembler: *std.build.LibExeObjStep,
    hex2bin: *std.build.LibExeObjStep,
};

fn buildToolchain(b: *std.build.Builder, outputDir: ?[]const u8, target: std.zig.CrossTarget, mode: std.builtin.Mode) !Toolchain {
    const debugger = b.addExecutable("debugger", "tools/debugger/main.zig");
    debugger.addPackage(packages.args);
    debugger.addPackage(packages.ihex);
    debugger.addPackage(packages.serial);
    debugger.addPackage(packages.spumk2);
    debugger.setTarget(target);
    debugger.setBuildMode(mode);
    if (outputDir) |od| debugger.setOutputDir(od);

    const emulator = b.addExecutable("emulator", "tools/emulator/pc-main.zig");
    emulator.addPackage(packages.args);
    emulator.addPackage(packages.ihex);
    emulator.addPackage(packages.spumk2);
    emulator.setTarget(target);
    emulator.setBuildMode(mode);
    if (outputDir) |od| emulator.setOutputDir(od);

    const disassembler = b.addExecutable("disassembler", "tools/disassembler/main.zig");
    disassembler.addPackage(packages.args);
    disassembler.addPackage(packages.ihex);
    disassembler.addPackage(packages.spumk2);
    disassembler.setTarget(target);
    disassembler.setBuildMode(mode);
    if (outputDir) |od| disassembler.setOutputDir(od);

    const assembler = b.addExecutable("assembler", "tools/assembler/main.zig");
    assembler.addPackage(packages.args);
    assembler.addPackage(packages.ihex);
    assembler.addPackage(packages.spumk2);
    assembler.setTarget(target);
    assembler.setBuildMode(mode);
    if (outputDir) |od| assembler.setOutputDir(od);

    const hex2bin = b.addExecutable("hex2bin", "tools/hex2bin/main.zig");
    hex2bin.addPackage(packages.args);
    hex2bin.addPackage(packages.ihex);
    hex2bin.setTarget(target);
    hex2bin.setBuildMode(mode);
    if (outputDir) |od| hex2bin.setOutputDir(od);

    return Toolchain{
        .hex2bin = hex2bin,
        .assembler = assembler,
        .disassembler = disassembler,
        .emulator = emulator,
        .debugger = debugger,
    };
}

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const nativeToolchain = try buildToolchain(b, null, target, mode);
    nativeToolchain.debugger.install();
    nativeToolchain.emulator.install();
    nativeToolchain.disassembler.install();
    nativeToolchain.assembler.install();
    nativeToolchain.hex2bin.install();

    // Cross-target
    {
        const debug_step = b.step("cross-build", "Builds all the toolchain for all cross targets.");

        const MyTarget = struct {
            target: std.zig.CrossTarget,
            folder: []const u8,
        };

        const targets = [_]MyTarget{
            .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-windows" }), .folder = "build/x86_64-windows" },
            // .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-macosx" }), .folder = "build/x86_64-macosx" }, // not supported by zig-serial atm
            .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-linux" }), .folder = "build/x86_64-linux" },
            .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "i386-windows" }), .folder = "build/i386-windows" }, // linker error _GetCommState
        };

        for (targets) |cross_target| {
            const crossToolchain = try buildToolchain(b, cross_target.folder, cross_target.target, mode);
            debug_step.dependOn(&crossToolchain.debugger.step);
            debug_step.dependOn(&crossToolchain.emulator.step);
            debug_step.dependOn(&crossToolchain.disassembler.step);
            debug_step.dependOn(&crossToolchain.assembler.step);
            debug_step.dependOn(&crossToolchain.hex2bin.step);
        }
    }

    const test_step = b.step("test", "Tests the code");
    test_step.dependOn(&b.addTest("tools/debugger/main.zig").step);
    test_step.dependOn(&b.addTest("tools/emulator/main.zig").step);
    test_step.dependOn(&b.addTest("tools/make-vhd/main.zig").step);
    test_step.dependOn(&b.addTest("tools/hex2bin/main.zig").step);

    const wasm_emulator = b.addStaticLibrary("emulator", "tools/emulator/web-main.zig");
    wasm_emulator.addPackage(packages.ihex);
    wasm_emulator.addPackage(packages.spumk2);
    wasm_emulator.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    wasm_emulator.setBuildMode(.ReleaseSafe);
    wasm_emulator.install();

    const make_vhd = b.addExecutable("make-vhd", "tools/make-vhd/main.zig");
    make_vhd.addPackage(packages.args);
    make_vhd.setTarget(target);
    make_vhd.setBuildMode(mode);
    make_vhd.install();

    inline for (examples) |src_file| {
        const step = nativeToolchain.assembler.run();
        step.addArgs(&[_][]const u8{
            "-o",
            src_file ++ ".hex",
            src_file ++ ".asm",
        });
        b.getInstallStep().dependOn(&step.step);
    }

    const assemble_step = nativeToolchain.assembler.run();
    assemble_step.addArgs(&[_][]const u8{
        "-o",
        "./soc/firmware/firmware.hex",
        "./soc/firmware/main.asm",
    });

    const gen_firmware_blob = nativeToolchain.hex2bin.run();
    gen_firmware_blob.step.dependOn(&assemble_step.step);
    gen_firmware_blob.addArgs(&[_][]const u8{
        "-o",
        "./soc/firmware/firmware.bin",
        "./soc/firmware/firmware.hex",
    });

    const refresh_cmd = make_vhd.run();
    refresh_cmd.step.dependOn(&gen_firmware_blob.step);
    refresh_cmd.addArgs(&[_][]const u8{
        "-o",
        "./soc/hw/src/builtin-rom.vhd",
        "./soc/firmware/firmware.bin",
    });

    b.getInstallStep().dependOn(&refresh_cmd.step);

    const emulate_cmd = nativeToolchain.emulator.run();
    emulate_cmd.step.dependOn(&assemble_step.step);
    emulate_cmd.addArgs(&[_][]const u8{
        "./soc/firmware/firmware.hex",
    });

    const emulate_step = b.step("emulate", "Run the emulator");
    emulate_step.dependOn(&emulate_cmd.step);

    const debug_cmd = nativeToolchain.debugger.run();

    const debug_step = b.step("debug", "Run the debugger");
    debug_step.dependOn(&debug_cmd.step);
}
