const std = @import("std");
const spu = @import("spu-mk2");

pub const BasicMemory = struct {
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
        _ = self;
        _ = address;
        return switch (address) {
            else => return error.BusError,
        };
    }

    pub fn write8(self: *Self, address: u16, value: u8) !void {
        _ = self;
        _ = address;
        _ = value;
        switch (address) {
            else => return error.BusError,
        }
    }

    pub fn read16(self: *Self, address: u16) !u16 {
        _ = self;
        _ = address;
        return switch (address) {
            else => return error.BusError,
        };
    }

    pub fn write16(self: *Self, address: u16, value: u16) !void {
        _ = self;
        _ = address;
        _ = value;
        switch (address) {
            else => return error.BusError,
        }
    }
};
