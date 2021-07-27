const std = @import("std");
const spu = @import("spu-mk2");

const SerialEmulator = @import("root").SerialEmulator;

pub const WasmDemoMachine = struct {
    const Self = @This();

    memory: [65536]u8 = undefined, // lower half is ROM, upper half is RAM

    pub const LoaderError = error{InvalidAddress};
    pub fn loadHexRecord(self: *Self, base: u32, data: []const u8) LoaderError!void {
        // std.debug.warn("load {}+{}: {X}\n", .{ base, data.len, data });
        for (data) |byte, offset| {
            const address = base + offset;
            switch (address) {
                0x0000...0xFFFF => |a| self.memory[a] = byte,
                else => return error.InvalidAddress,
            }
        }
    }

    pub fn read8(self: *Self, address: u16) !u8 {
        return switch (address) {
            0x7FFE...0x7FFF => return error.BusError,
            else => self.memory[address],
        };
    }

    pub fn write8(self: *Self, address: u16, value: u8) !void {
        switch (address) {
            0x0000...0x7FFD => return error.BusError,
            0x7FFE...0x7FFF => return error.BusError,
            0x8000...0xFFFF => self.memory[address] = value,
        }
    }

    pub fn read16(self: *Self, address: u16) !u16 {
        return switch (address) {
            0x7FFE...0x7FFF => try SerialEmulator.read(),
            else => std.mem.readIntLittle(u16, self.memory[address..][0..2]),
        };
    }

    pub fn write16(self: *Self, address: u16, value: u16) !void {
        return switch (address) {
            0x0000...0x7FFD => return error.BusError,
            0x7FFE...0x7FFF => try SerialEmulator.write(value),
            0x8000...0xFFFF => std.mem.writeIntLittle(u16, self.memory[address..][0..2], value),
        };
    }
};
