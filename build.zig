const std = @import("std");
const zpm = @import(".zpm/pkgs.zig");

const packages = zpm.pkgs;

const examples = [_][]const u8{
    // "apps/hello-world/main",
    // "apps/ascii-printer/main",
};

pub fn addTest(b: *std.build.Builder, global_step: *std.build.Step, comptime tool_name: []const u8, src: []const u8) *std.build.LibExeObjStep {
    const test_runner = b.addTest(src);
    const test_step = b.step("test-" ++ tool_name, "Runs the test suite for " ++ tool_name);
    test_step.dependOn(&test_runner.step);
    global_step.dependOn(&test_runner.step);
    return test_runner;
}

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const hex2bin = b.addExecutable("hex2bin", "tools/hex2bin/main.zig");
    hex2bin.addPackage(packages.args);
    hex2bin.addPackage(packages.ihex);
    hex2bin.setTarget(target);
    hex2bin.setBuildMode(mode);
    // hex2bin.install();

    const emulator = b.addExecutable("spu-emulator", "tools/emulator/pc-main.zig");
    emulator.addPackage(packages.args);
    emulator.addPackage(packages.ihex);
    emulator.addPackage(packages.@"spu-mk2");
    emulator.setTarget(target);
    emulator.setBuildMode(mode);
    emulator.install();

    const disassembler = b.addExecutable("spu-disasm", "tools/disassembler/main.zig");
    disassembler.addPackage(packages.args);
    disassembler.addPackage(packages.ihex);
    disassembler.addPackage(packages.@"spu-mk2");
    disassembler.setTarget(target);
    disassembler.setBuildMode(mode);
    disassembler.install();

    const assembler = b.addExecutable("spu-as", "tools/assembler/main.zig");
    assembler.addPackage(packages.args);
    assembler.addPackage(packages.ihex);
    assembler.addPackage(packages.@"spu-mk2");
    assembler.setTarget(target);
    assembler.setBuildMode(mode);
    assembler.install();

    const test_step = b.step("test", "Runs the full test suite");
    {
        const asm_test = addTest(b, test_step, "assembler", "tools/assembler/main.zig");
        asm_test.addPackage(zpm.pkgs.@"spu-mk2");
        asm_test.addPackage(zpm.pkgs.args);

        _ = addTest(b, test_step, "debugger", "tools/debugger/main.zig");
        _ = addTest(b, test_step, "emulator", "tools/emulator/pc-main.zig");
    }

    const mkfirmware = b.addSystemCommand(&[_][]const u8{
        "mkdir", "-p", "zig-out/firmware/",
    });

    inline for (examples) |src_file| {
        const step = assembler.run();
        step.addArgs(&[_][]const u8{
            "-o",
            "./zig-out/firmware/" ++ std.fs.path.basename(std.fs.path.dirname(src_file).?) ++ ".hex",
            src_file ++ ".asm",
        });
        step.step.dependOn(&mkfirmware.step);
        b.getInstallStep().dependOn(&step.step);
    }

    const assemble_step = assembler.run();
    assemble_step.addArgs(&[_][]const u8{
        "-o",
        "./zig-out/firmware/ashet-bios.hex",
        "./apps/ashet-bios/main.asm",
    });
    assemble_step.step.dependOn(&mkfirmware.step);

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

    const emulate_cmd = emulator.run();
    emulate_cmd.step.dependOn(&assemble_step.step);
    emulate_cmd.addArgs(&[_][]const u8{
        "./zig-out/firmware/firmware.hex",
    });
    emulate_cmd.step.dependOn(&mkfirmware.step);
    {
        const assemble_wasm_step = assembler.run();
        assemble_wasm_step.addArgs(&[_][]const u8{
            "-o",
            "./zig-out/firmware/wasm.hex",
            "./apps/web-firmware/main.asm",
        });
        assemble_wasm_step.step.dependOn(&mkfirmware.step);

        const gen_wasm_firmware_blob = hex2bin.run();
        gen_wasm_firmware_blob.step.dependOn(&assemble_wasm_step.step);
        gen_wasm_firmware_blob.addArgs(&[_][]const u8{
            "-o",
            "./zig-out/firmware/wasm.bin",
            "./zig-out/firmware/wasm.hex",
        });
        gen_wasm_firmware_blob.step.dependOn(&mkfirmware.step);

        const wasm_emulator = b.addSharedLibrary("emulator", "tools/emulator/web-main.zig", .unversioned);
        wasm_emulator.addPackage(packages.ihex);
        wasm_emulator.addPackage(packages.@"spu-mk2");
        wasm_emulator.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
        wasm_emulator.setBuildMode(mode);
        wasm_emulator.step.dependOn(&gen_wasm_firmware_blob.step);

        const install_step = b.addInstallArtifact(wasm_emulator);

        const wasm_step = b.step("wasm", "Builds the WASM emulator");
        wasm_step.dependOn(&install_step.step);
    }

    // Cross-target
    // {
    //     const cross_step = b.step("cross-build", "Builds all the toolchain for all cross targets.");

    //     const MyTarget = struct {
    //         target: std.zig.CrossTarget,
    //         folder: []const u8,
    //     };

    //     const targets = [_]MyTarget{
    //         .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-windows" }), .folder = "build/x86_64-windows" },
    //         // .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-macosx" }), .folder = "build/x86_64-macosx" }, // not supported by zig-serial atm
    //         .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "x86_64-linux" }), .folder = "build/x86_64-linux" },
    //         .{ .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = "i386-windows" }), .folder = "build/i386-windows" }, // linker error _GetCommState
    //     };

    //     for (targets) |cross_target| {
    //         const crossToolchain = try buildToolchain(b, sdl_sdk, cross_target.folder, cross_target.target, mode);
    //         cross_step.dependOn(&crossToolchain.debugger.step);
    //         cross_step.dependOn(&crossToolchain.emulator.step);
    //         cross_step.dependOn(&crossToolchain.disassembler.step);
    //         cross_step.dependOn(&crossToolchain.assembler.step);
    //         cross_step.dependOn(&crossToolchain.hex2bin.step);
    //         cross_step.dependOn(&crossToolchain.ashet_emulator.step);
    //     }
    // }
}
