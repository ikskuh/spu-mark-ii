const std = @import("std");
const spu = @import("spu-mk2");

pub const BasicMemory = struct {
    const Self = @This();

    interface: spu.MemoryInterface = spu.MemoryInterface{
        .readByteFn = readByte,
        .writeByteFn = writeByte,
        .readWordFn = readWord,
        .writeWordFn = writeWord,
    },

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

    fn readByte(interface: *spu.MemoryInterface, address: u16) spu.MemoryInterface.Error!u8 {
        const self = @fieldParentPtr(Self, "interface", interface);
        return switch (address) {
            else => return error.BusError,
        };
    }

    fn writeByte(interface: *spu.MemoryInterface, address: u16, value: u8) spu.MemoryInterface.Error!void {
        const self = @fieldParentPtr(Self, "interface", interface);
        switch (address) {
            else => return error.BusError,
        }
    }

    fn readWord(interface: *spu.MemoryInterface, address: u16) spu.MemoryInterface.Error!u16 {
        const self = @fieldParentPtr(Self, "interface", interface);
        return switch (address) {
            else => return error.BusError,
        };
    }

    fn writeWord(interface: *spu.MemoryInterface, address: u16, value: u16) spu.MemoryInterface.Error!void {
        const self = @fieldParentPtr(Self, "interface", interface);
        switch (address) {
            else => return error.BusError,
        }
    }
};
