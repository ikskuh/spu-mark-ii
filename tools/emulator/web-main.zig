const std = @import("std");

const spu = @import("spu-mk2");
const common = @import("shared.zig");

var memory = common.BasicMemory{};
var emulator: spu.SpuMk2 = undefined;

const bootrom = @embedFile("../../soc/firmware/firmware.bin");

pub fn dumpState(emu: *spu.SpuMk2) !void {
    _ = emu;
}

pub fn dumpTrace(emu: *spu.SpuMk2, ip: u16, instruction: spu.Instruction, input0: u16, input1: u16, output: u16) !void {
    _ = emu;
    _ = ip;
    _ = instruction;
    _ = input0;
    _ = input1;
    _ = output;
}

export fn init() void {
    serialWrite("a", 1);
    emulator = spu.SpuMk2.init(&memory.interface);
    serialWrite("b", 1);

    std.mem.copy(u8, &memory.rom, bootrom[0..std.math.min(memory.rom.len, bootrom.len)]);
    serialWrite("c", 1);
}

export fn run(steps: u32) u32 {
    emulator.runBatch(steps) catch |err| switch (err) {
        error.BadInstruction => return 1,
        error.UnalignedAccess => return 2,
        error.BusError => return 3,
    };
    return 0;
}

extern fn serialRead(data: [*]u8, len: u32) u32;

extern fn serialWrite(data: [*]const u8, len: u32) void;

pub const SerialEmulator = struct {
    pub fn read() !u16 {
        var value: [1]u8 = undefined;
        if (serialRead(&value, 1) == 1) {
            return @as(u16, value[0]);
        } else {
            return 0xFFFF;
        }
    }

    pub fn write(value: u16) !void {
        serialWrite(&[_]u8{@truncate(u8, value)}, 1);
    }
};

// pub fn panic(message: []const u8, stackTrace: ?*std.builtin.StackTrace) noreturn {
//     serialWrite(message.ptr, message.len);

//     // @breakpoint();
//     unreachable;
// }
