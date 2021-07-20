const std = @import("std");
const zpm = @import(".zpm/pkgs.zig");

const packages = zpm.pkgs;

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
    ashet_emulator: *std.build.LibExeObjStep,
};

fn buildToolchain(b: *std.build.Builder, outputDir: ?[]const u8, target: std.zig.CrossTarget, mode: std.builtin.Mode) !Toolchain {
    const debugger = b.addExecutable("debugger", "tools/debugger/main.zig");
    debugger.addPackage(packages.args);
    debugger.addPackage(packages.ihex);
    debugger.addPackage(packages.serial);
    debugger.addPackage(packages.@"spu-mk2");
    debugger.setTarget(target);
    debugger.setBuildMode(mode);
    if (outputDir) |od| debugger.setOutputDir(od);

    const emulator = b.addExecutable("emulator", "tools/emulator/pc-main.zig");
    emulator.addPackage(packages.args);
    emulator.addPackage(packages.ihex);
    emulator.addPackage(packages.@"spu-mk2");
    emulator.linkSystemLibrary("SDL2");
    emulator.setTarget(target);
    emulator.setBuildMode(mode);

    if (outputDir) |od| emulator.setOutputDir(od);

    const ashet_emulator = b.addExecutable("ashet", "tools/ashet-emulator/main.zig");
    ashet_emulator.addPackage(packages.sdl2);
    ashet_emulator.addPackage(packages.ihex);
    ashet_emulator.addPackage(packages.args);
    ashet_emulator.addPackage(packages.@"spu-mk2");
    ashet_emulator.linkSystemLibrary("SDL2");
    ashet_emulator.setTarget(target);
    ashet_emulator.setBuildMode(mode);
    if (outputDir) |od| ashet_emulator.setOutputDir(od);

    const disassembler = b.addExecutable("disassembler", "tools/disassembler/main.zig");
    disassembler.addPackage(packages.args);
    disassembler.addPackage(packages.ihex);
    disassembler.addPackage(packages.@"spu-mk2");
    disassembler.setTarget(target);
    disassembler.setBuildMode(mode);
    if (outputDir) |od| disassembler.setOutputDir(od);

    const assembler = b.addExecutable("assembler", "tools/assembler/main.zig");
    assembler.addPackage(packages.args);
    assembler.addPackage(packages.ihex);
    assembler.addPackage(packages.@"spu-mk2");
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
        .ashet_emulator = ashet_emulator,
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
    nativeToolchain.ashet_emulator.install();

    const test_step = b.step("test", "Tests the code");
    test_step.dependOn(&b.addTest("tools/debugger/main.zig").step);
    test_step.dependOn(&b.addTest("tools/emulator/pc-main.zig").step);
    test_step.dependOn(&b.addTest("tools/make-vhd/main.zig").step);
    test_step.dependOn(&b.addTest("tools/hex2bin/main.zig").step);

    const make_vhd = b.addExecutable("make-vhd", "tools/make-vhd/main.zig");
    make_vhd.addPackage(packages.args);
    make_vhd.setTarget(target);
    make_vhd.setBuildMode(mode);
    make_vhd.install();

    const hex2mem = b.addExecutable("hex2mem", "tools/hex2mem/main.zig");
    hex2mem.addPackage(packages.args);
    hex2mem.addPackage(packages.ihex);
    hex2mem.setTarget(target);
    hex2mem.setBuildMode(mode);
    hex2mem.install();

    inline for (examples) |src_file| {
        const step = nativeToolchain.assembler.run();
        step.addArgs(&[_][]const u8{
            "-o",
            "./zig-out/firmware/" ++ std.fs.path.basename(std.fs.path.dirname(src_file).?) ++ ".hex",
            src_file ++ ".asm",
        });
        b.getInstallStep().dependOn(&step.step);
    }

    const assemble_step = nativeToolchain.assembler.run();
    assemble_step.addArgs(&[_][]const u8{
        "-o",
        "./zig-out/firmware/firmware.hex",
        "./apps/firmware/main.asm",
    });

    const gen_firmware_blob = nativeToolchain.hex2bin.run();
    gen_firmware_blob.step.dependOn(&assemble_step.step);
    gen_firmware_blob.addArgs(&[_][]const u8{
        "-o",
        "./zig-out/firmware/firmware.bin",
        "./zig-out/firmware/firmware.hex",
    });

    const firmware_step = b.step("firmware", "Builds the BIOS for Ashet");
    firmware_step.dependOn(&gen_firmware_blob.step);

    // const refresh_cmd = make_vhd.run();
    // refresh_cmd.step.dependOn(&gen_firmware_blob.step);
    // refresh_cmd.addArgs(&[_][]const u8{
    //     "--output",
    //     "./soc/vhdl/src/builtin-rom.vhd",
    //     "./zig-out/firmware/firmware.bin",
    // });

    // const gen_mem_file = hex2mem.run();
    // gen_mem_file.step.dependOn(&assemble_step.step);
    // gen_mem_file.addArgs(&[_][]const u8{
    //     "--output",
    //     "./soc/vhdl/firmware.mem",
    //     "./zig-out/firmware/firmware.hex",
    // });

    // b.getInstallStep().dependOn(&gen_mem_file.step);
    // b.getInstallStep().dependOn(&refresh_cmd.step);

    const emulate_cmd = nativeToolchain.emulator.run();
    emulate_cmd.step.dependOn(&assemble_step.step);
    emulate_cmd.addArgs(&[_][]const u8{
        "./zig-out/firmware/firmware.hex",
    });

    {
        const wasm_emulator = b.addStaticLibrary("emulator", "tools/emulator/web-main.zig");
        wasm_emulator.addPackage(packages.ihex);
        wasm_emulator.addPackage(packages.@"spu-mk2");
        wasm_emulator.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
        wasm_emulator.setBuildMode(.ReleaseSafe);
        wasm_emulator.step.dependOn(&gen_firmware_blob.step);

        const wasm_step = b.step("wasm", "Builds the WASM emulator");
        wasm_step.dependOn(&wasm_emulator.step);
    }

    const bitmap_converter = b.addExecutable("bit-loader", "tools/bit-loader/main.zig");
    bitmap_converter.addPackage(packages.args);
    bitmap_converter.setTarget(target);
    bitmap_converter.setBuildMode(mode);
    bitmap_converter.install();

    const emulate_step = b.step("emulate", "Run the emulator");
    emulate_step.dependOn(&emulate_cmd.step);

    const debug_cmd = nativeToolchain.debugger.run();

    const debug_step = b.step("debug", "Run the debugger");
    debug_step.dependOn(&debug_cmd.step);

    const emulator_step = b.step("emulator", "Compiles the emulator");
    emulator_step.dependOn(&nativeToolchain.emulator.step);

    // Cross-target
    {
        const cross_step = b.step("cross-build", "Builds all the toolchain for all cross targets.");

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
            cross_step.dependOn(&crossToolchain.debugger.step);
            cross_step.dependOn(&crossToolchain.emulator.step);
            cross_step.dependOn(&crossToolchain.disassembler.step);
            cross_step.dependOn(&crossToolchain.assembler.step);
            cross_step.dependOn(&crossToolchain.hex2bin.step);
            cross_step.dependOn(&crossToolchain.ashet_emulator.step);
        }
    }
}
