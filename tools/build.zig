const std = @import("std");

const packages = struct {
    const args = std.build.Pkg{
        .name = "args",
        .path = "./modules/zig-args/args.zig",
    };
    const ihex = std.build.Pkg{
        .name = "ihex",
        .path = "./modules/zig-ihex/ihex.zig",
    };
};

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    {
        const test_step = b.step("test", "Tests the code");

        const debugger_test = b.addTest("debugger/main.zig");
        test_step.dependOn(&debugger_test.step);

        const emulator_test = b.addTest("emulator/main.zig");
        test_step.dependOn(&emulator_test.step);
    }

    {
        const debugger = b.addExecutable("debugger", "debugger/main.zig");
        debugger.addCSourceFile("debugger/serial-support.c", &[_][]const u8{});
        debugger.linkLibC();
        debugger.addPackage(packages.args);
        debugger.addPackage(packages.ihex);
        debugger.setTarget(target);
        debugger.setBuildMode(mode);
        debugger.install();

        const run_cmd = debugger.run();
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("debug", "Run the debugger");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const emulator = b.addExecutable("emulator", "emulator/main.zig");
        emulator.addPackage(packages.args);
        emulator.addPackage(packages.ihex);
        emulator.setTarget(target);
        emulator.setBuildMode(mode);
        emulator.install();

        const run_cmd = emulator.run();
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("emulate", "Run the emulator");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const sources = [_][]const u8{
            "assembler/main.c",
            "assembler/lexer.yy.c",
            "assembler/codegen.c",
            "assembler/hexgen.c",
            "assembler/labels.c",
            "assembler/patches.c",
            "assembler/stringtable.c",
        };

        const flexfile = b.addSystemCommand(&[_][]const u8{
            "flex",
            "-o",
            "assembler/lexer.yy.c",
            "-8",
            "--yylineno",
            "--prefix=lex_",
            "--interactive",
            "assembler/lexer.l",
        });

        const assembler = b.addExecutable("assembler", null);
        assembler.step.dependOn(&flexfile.step);
        assembler.addIncludeDir("include");

        for (sources) |src| {
            assembler.addCSourceFile(src, &[_][]const u8{
                "-Wall", "-Wextra", "-pedantic",
            });
        }

        assembler.linkLibC();
        assembler.setTarget(target);
        assembler.setBuildMode(mode);
        assembler.install();
    }
}
