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

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const test_step = b.step("test", "Tests the code");
    test_step.dependOn(&b.addTest("tools/debugger/main.zig").step);
    test_step.dependOn(&b.addTest("tools/emulator/main.zig").step);
    test_step.dependOn(&b.addTest("tools/make-vhd/main.zig").step);
    test_step.dependOn(&b.addTest("tools/hex2bin/main.zig").step);

    const debugger = b.addExecutable("debugger", "tools/debugger/main.zig");
    debugger.addPackage(packages.args);
    debugger.addPackage(packages.ihex);
    debugger.addPackage(packages.serial);
    debugger.addPackage(packages.spumk2);
    debugger.setTarget(target);
    debugger.setBuildMode(mode);
    debugger.install();

    const emulator = b.addExecutable("emulator", "tools/emulator/pc-main.zig");
    emulator.addPackage(packages.args);
    emulator.addPackage(packages.ihex);
    emulator.addPackage(packages.spumk2);
    emulator.setTarget(target);
    emulator.setBuildMode(mode);
    emulator.install();

    const wasm_emulator = b.addStaticLibrary("emulator", "tools/emulator/web-main.zig");
    wasm_emulator.addPackage(packages.ihex);
    wasm_emulator.addPackage(packages.spumk2);
    wasm_emulator.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    wasm_emulator.setBuildMode(.ReleaseSafe);
    wasm_emulator.install();

    const disassembler = b.addExecutable("disassembler", "tools/disassembler/main.zig");
    disassembler.addPackage(packages.args);
    disassembler.addPackage(packages.ihex);
    disassembler.addPackage(packages.spumk2);
    disassembler.setTarget(target);
    disassembler.setBuildMode(mode);
    disassembler.install();

    const assembler = b.addExecutable("assembler", "tools/assembler/main.zig");
    assembler.addPackage(packages.args);
    assembler.addPackage(packages.ihex);
    assembler.addPackage(packages.spumk2);
    assembler.setTarget(target);
    assembler.setBuildMode(mode);
    assembler.install();

    const hex2bin = b.addExecutable("hex2bin", "tools/hex2bin/main.zig");
    hex2bin.addPackage(packages.args);
    hex2bin.addPackage(packages.ihex);
    hex2bin.setTarget(target);
    hex2bin.setBuildMode(mode);
    hex2bin.install();

    const make_vhd = b.addExecutable("make-vhd", "tools/make-vhd/main.zig");
    make_vhd.addPackage(packages.args);
    make_vhd.setTarget(target);
    make_vhd.setBuildMode(mode);
    make_vhd.install();

    inline for (examples) |src_file| {
        const step = assembler.run();
        step.addArgs(&[_][]const u8{
            "-o",
            src_file ++ ".hex",
            src_file ++ ".asm",
        });
        b.getInstallStep().dependOn(&step.step);
    }

    const assemble_step = assembler.run();
    assemble_step.addArgs(&[_][]const u8{
        "-o",
        "./soc/firmware/firmware.hex",
        "./soc/firmware/main.asm",
    });

    const gen_firmware_blob = hex2bin.run();
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

    const emulate_cmd = emulator.run();
    emulate_cmd.step.dependOn(&assemble_step.step);
    emulate_cmd.addArgs(&[_][]const u8{
        "./soc/firmware/firmware.hex",
    });

    const emulate_step = b.step("emulate", "Run the emulator");
    emulate_step.dependOn(&emulate_cmd.step);

    const debug_cmd = debugger.run();

    const debug_step = b.step("debug", "Run the debugger");
    debug_step.dependOn(&debug_cmd.step);
}
