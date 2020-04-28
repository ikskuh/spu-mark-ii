const std = @import("std");

usingnamespace @import("emulator.zig");

var emulator: Emulator = undefined;

const bootrom = @embedFile("../../soc/firmware/firmware.bin");

export fn init() void {
    emulator = Emulator.init();

    std.mem.copy(u8, &emulator.rom, bootrom);
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
