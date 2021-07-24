const std = @import("std");

const spu = @import("spu-mk2");
const common = @import("shared.zig");

var emulator: spu.SpuMk2(WasmDemoMachine) = undefined;

const bootrom = @embedFile("../../zig-out/firmware/wasm.bin");

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
    // serialWrite("a", 1);
    emulator = spu.SpuMk2(WasmDemoMachine).init(.{});
    // serialWrite("b", 1);
    std.mem.copy(u8, &emulator.memory.rom, bootrom[0..std.math.min(emulator.memory.rom.len, bootrom.len)]);
    // serialWrite("c", 1);
}

export fn run(steps: u32) u32 {
    emulator.runBatch(steps) catch |err| {
        emulator.reset();
        switch (err) {
            error.BadInstruction => return 1,
            error.UnalignedAccess => return 2,
            error.BusError => return 3,
            error.DebugBreak => return 4,
        }
    };
    return 0;
}

export fn resetCpu() void {
    emulator.triggerInterrupt(.reset);
}

export fn invokeNmi() void {
    emulator.triggerInterrupt(.nmi);
}

export fn getRomPtr() [*]u8 {
    return &emulator.memory.rom;
}

export fn getRamPtr() [*]u8 {
    return &emulator.memory.ram;
}

extern fn invokeJsPanic() noreturn;

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

pub fn panic(message: []const u8, stackTrace: ?*std.builtin.StackTrace) noreturn {
    serialWrite(message.ptr, message.len);
    _ = stackTrace;
    invokeJsPanic();
}

pub fn log(level: anytype, comptime fmt: []const u8, args: anytype) void {
    _ = level;
    _ = fmt;
    _ = args;
    //
}

pub const WasmDemoMachine = struct {
    const Self = @This();

    rom: [32768]u8 = undefined, // lower half is ROM
    ram: [32768]u8 = undefined, // upper half is RAM

    pub const LoaderError = error{InvalidAddress};
    pub fn loadHexRecord(self: *Self, base: u32, data: []const u8) LoaderError!void {
        // std.debug.warn("load {}+{}: {X}\n", .{ base, data.len, data });
        for (data) |byte, offset| {
            const address = base + offset;
            switch (address) {
                0x0000...0x7FFF => |a| self.rom[a] = byte,
                0x8000...0xFFFF => |a| self.ram[a - 0x8000] = byte,
                else => return error.InvalidAddress,
            }
        }
    }

    pub fn read8(self: *Self, address: u16) !u8 {
        return switch (address) {
            0x0000...0x7FFD => self.rom[address],
            0x7FFE...0x7FFF => return error.BusError,
            0x8000...0xFFFF => self.ram[address],
        };
    }

    pub fn write8(self: *Self, address: u16, value: u8) !void {
        switch (address) {
            0x0000...0x7FFD => return error.BusError,
            0x7FFE...0x7FFF => return error.BusError,
            0x8000...0xFFFF => self.ram[address] = value,
        }
    }

    pub fn read16(self: *Self, address: u16) !u16 {
        return switch (address) {
            0x0000...0x7FFD => std.mem.readIntLittle(u16, self.rom[address..][0..2]),
            0x7FFE...0x7FFF => try SerialEmulator.read(),
            0x8000...0xFFFF => std.mem.readIntLittle(u16, self.ram[address - 0x8000 ..][0..2]),
        };
    }

    pub fn write16(self: *Self, address: u16, value: u16) !void {
        return switch (address) {
            0x0000...0x7FFD => std.mem.writeIntLittle(u16, self.rom[address..][0..2], value),
            0x7FFE...0x7FFF => try SerialEmulator.write(value),
            0x8000...0xFFFF => std.mem.writeIntLittle(u16, self.ram[address - 0x8000 ..][0..2], value),
        };
    }
};
