const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("async-lpc", "src/main.zig");
    exe.addPackage(std.build.Pkg{
        .name = "lpc1768",
        .path = "libs/lpc1768/lpc1768.zig",
    });
    exe.setTarget(std.zig.CrossTarget{
        .cpu_arch = .thumb,
        .cpu_model = .{
            .explicit = &std.Target.arm.cpu.cortex_m3,
        },
        .os_tag = .freestanding,
        .abi = .eabi,
    });
    exe.strip = true;
    exe.setBuildMode(.ReleaseSafe);
    exe.install();
    exe.setLinkerScriptPath("./src/linker.ld");

    const create_hex = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-objcopy",
        "-R",
        "stack",
        "-R",
        ".data",
        "-R",
        ".bss",
        "-R",
        ".debug_abbrev",
        "-O",
        "ihex",
        // "zig-cache/bin/async-lpc",
        // "async-lpc.hex",
    });
    create_hex.addArtifactArg(exe);
    create_hex.addArg("firmware.hex");

    const hex_step = b.step("hex", "Creates a flashable ihex file");
    hex_step.dependOn(&create_hex.step);

    const create_bin = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-objcopy",
        "-I",
        "ihex",
        "-O",
        "binary",
        "firmware.hex",
        "firmware.bin",
    });
    create_bin.step.dependOn(&create_hex.step);

    const bin_step = b.step("bin", "Creates a flashable binary file");
    bin_step.dependOn(&create_bin.step);

    const flash_step = b.step("flash", "Creates a hex file and flashes it.");
    if (b.option([]const u8, "flash-drive", "If given, the file is deployed via mtools/fat32")) |file_name| {
        const copy_flash = b.addSystemCommand(&[_][]const u8{
            "mcopy",
            "-D",
            "o", // override the file without asking
            "firmware.bin", // from firmware.bin
            "::firmware.bin", // to D:\firmware.bin
            "-i", // MUST BE LAST
        });
        copy_flash.addArg(file_name);

        copy_flash.step.dependOn(&create_bin.step);

        flash_step.dependOn(&copy_flash.step);
    } else {

        // This is 100% machine dependant
        const run_flash = b.addSystemCommand(&[_][]const u8{
            "flash-magic",
            "COM(5, 115200)",
            "DEVICE(LPC1768, 0.000000, 0)",
            "HARDWARE(BOOTEXEC, 50, 100)",
            "ERASEUSED(Z:\\home\\felix\\projects\\lowlevel\\async-lpc\\async-lpc.hex, PROTECTISP)",
            "HEXFILE(Z:\\home\\felix\\projects\\lowlevel\\async-lpc\\async-lpc.hex, NOCHECKSUMS, NOFILL, PROTECTISP)",
        });
        run_flash.step.dependOn(&create_hex.step);

        flash_step.dependOn(&run_flash.step);
    }

    const run_term = b.addSystemCommand(&[_][]const u8{
        "picocom",
        "--baud",
        "19200",
        "--lower-rts", // Disable programmer
        "--lower-dtr", // Disable reset
        "/dev/ttyUSB0",
    });

    const term_step = b.step("terminal", "Starts picocom on the correct port");
    term_step.dependOn(&run_term.step);
}
