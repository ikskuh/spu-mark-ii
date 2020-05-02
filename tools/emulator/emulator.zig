const std = @import("std");

usingnamespace @import("spu-mk2");

pub const Emulator = struct {
    const Self = @This();
    const Stage = enum {
        decode,
        execute,
        postprocess,
    };

    rom: [16384]u8,
    ram0: [4096]u8,
    ram1: [32768]u8,

    ip: u16,
    bp: u16,
    fr: FlagRegister,
    sp: u16,

    bus_addr: u16,
    stage: Stage,

    count: u64 = 0,

    tracing: bool = false,

    pub fn init() Self {
        return Self{
            .rom = [1]u8{0} ** 16384,
            .ram0 = [1]u8{0} ** 4096,
            .ram1 = [1]u8{0} ** 32768,

            .ip = 0x0000,
            .fr = std.mem.zeroes(FlagRegister),
            .bp = undefined,
            .sp = undefined,

            .bus_addr = undefined,
            .stage = undefined,
        };
    }

    fn readByte(self: *Self, address: u16) !u8 {
        return switch (address) {
            0x0000...0x3FFF => self.rom[address],
            0x4000...0x4FFF => @truncate(u8, try @import("root").SerialEmulator.read()),
            0x6000...0x6FFF => self.ram0[address - 0x6000],
            0x8000...0xFFFF => self.ram1[address - 0x8000],
            else => {
                self.bus_addr = address;
                return error.BusError;
            },
        };
    }

    fn writeByte(self: *Self, address: u16, value: u8) !void {
        return switch (address) {
            0x4000...0x4FFF => try @import("root").SerialEmulator.write(value),
            0x6000...0x6FFF => self.ram0[address - 0x6000] = value,
            0x8000...0xFFFF => self.ram1[address - 0x8000] = value,
            else => {
                self.bus_addr = address;
                return error.BusError;
            },
        };
    }

    fn readWord(self: *Self, address: u16) !u16 {
        if ((address & 1) != 0)
            return error.UnalignedAccess;
        return switch (address) {
            0x0000...0x3FFF => std.mem.readIntLittle(u16, self.rom[address..][0..2]),
            0x4000...0x4FFF => try @import("root").SerialEmulator.read(),
            0x6000...0x6FFF => std.mem.readIntLittle(u16, self.ram0[address - 0x6000 ..][0..2]),
            0x8000...0xFFFF => std.mem.readIntLittle(u16, self.ram1[address - 0x8000 ..][0..2]),
            else => {
                self.bus_addr = address;
                return error.BusError;
            },
        };
    }

    fn writeWord(self: *Self, address: u16, value: u16) !void {
        if ((address & 1) != 0)
            return error.UnalignedAccess;
        return switch (address) {
            0x4000...0x4FFF => try @import("root").SerialEmulator.write(value),
            0x6000...0x6FFF => std.mem.writeIntLittle(u16, self.ram0[address - 0x6000 ..][0..2], value),
            0x8000...0xFFFF => std.mem.writeIntLittle(u16, self.ram1[address - 0x8000 ..][0..2], value),
            else => {
                self.bus_addr = address;
                return error.BusError;
            },
        };
    }

    fn fetch(self: *Self) !u16 {
        const value = try self.readWord(self.ip);
        self.ip +%= 2;
        return value;
    }

    fn peek(self: *Self) !u16 {
        return try self.readWord(self.sp);
    }

    fn pop(self: *Self) !u16 {
        const value = try self.readWord(self.sp);
        self.sp +%= 2;
        return value;
    }

    fn push(self: *Self, value: u16) !void {
        self.sp -%= 2;
        try self.writeWord(self.sp, value);
    }

    fn executeSingle(self: *Self) !void {
        self.stage = .decode;

        const start_ip = self.ip;

        const instruction = @bitCast(Instruction, try self.fetch());

        if (instruction.reserved == 1) {
            switch (@bitCast(u16, instruction)) {
                0x8000 => self.tracing = false,
                0x8001 => self.tracing = true,

                else => return error.BadInstruction,
            }
            return;
        }

        const execute = switch (instruction.condition) {
            .always => true,
            .when_zero => self.fr.zero,
            .not_zero => !self.fr.zero,
            .greater_zero => !self.fr.zero and !self.fr.negative,
            .less_than_zero => !self.fr.zero and self.fr.negative,
            .greater_or_equal_zero => self.fr.zero or !self.fr.negative,
            .less_or_equal_zero => self.fr.zero or self.fr.negative,
            .overflow => self.fr.carry,
        };

        if (execute) {
            const input0 = switch (instruction.input0) {
                .zero => @as(u16, 0),
                .immediate => try self.fetch(),
                .peek => try self.peek(),
                .pop => try self.pop(),
            };
            const input1 = switch (instruction.input1) {
                .zero => @as(u16, 0),
                .immediate => try self.fetch(),
                .peek => try self.peek(),
                .pop => try self.pop(),
            };

            self.stage = .execute;

            const output = switch (instruction.command) {
                .copy => input0,
                .ipget => self.ip +% 2 *% input0,
                .get => try self.readWord(self.bp +% 2 *% input0),
                .set => blk: {
                    try self.writeWord(self.bp +% 2 *% input0, input1);
                    break :blk input1;
                },
                .store8 => blk: {
                    const val = @truncate(u8, input1);
                    try self.writeByte(input0, val);
                    break :blk val;
                },
                .store16 => blk: {
                    try self.writeWord(input0, input1);
                    break :blk input1;
                },
                .load8 => try self.readByte(input0),
                .load16 => try self.readWord(input0),
                .frget => @bitCast(u16, self.fr) & ~input1,
                .frset => blk: {
                    const value = (@bitCast(u16, self.fr) & input1) | (input0 & ~input1);
                    self.fr = @bitCast(FlagRegister, value);
                    break :blk value;
                },
                .bpget => self.bp,
                .bpset => blk: {
                    self.bp = input0;
                    break :blk self.bp;
                },
                .spget => self.sp,
                .spset => blk: {
                    self.sp = input0;
                    break :blk self.sp;
                },
                .add => blk: {
                    var result: u16 = undefined;
                    self.fr.carry = @addWithOverflow(u16, input0, input1, &result);
                    break :blk result;
                },
                .sub => blk: {
                    var result: u16 = undefined;
                    self.fr.carry = @subWithOverflow(u16, input0, input1, &result);
                    break :blk result;
                },
                .mul => blk: {
                    var result: u16 = undefined;
                    self.fr.carry = @mulWithOverflow(u16, input0, input1, &result);
                    break :blk result;
                },
                .div => input0 / input1,
                .mod => input0 % input1,
                .@"and" => input0 & input1,
                .@"or" => input0 | input1,
                .xor => input0 ^ input1,
                .not => ~input0,
                .signext => if ((input0 & 0x80) != 0)
                    (input0 & 0xFF) | 0xFF00
                else
                    (input0 & 0xFF),
                .rol => (input0 << 1) | (input0 >> 15),
                .ror => (input0 >> 1) | (input0 << 15),
                .bswap => (input0 << 8) | (input0 >> 8),
                .asr => (input0 & 0x8000) | (input0 >> 1),
                .lsl => input0 << 1,
                .lsr => input0 >> 1,
                .undefined0, .undefined1 => return error.BadInstruction,
            };

            self.stage = .postprocess;
            switch (instruction.output) {
                .discard => {},
                .push => try self.push(output),
                .jump => self.ip = output,
                .jump_relative => self.ip +%= 2 * output,
            }
            if (instruction.modify_flags) {
                self.fr.negative = (output & 0x8000) != 0;
                self.fr.zero = (output == 0x0000);
            }
            if (self.tracing) {
                std.debug.warn("offset={X:0>4} instr={}\tinput0={X:0>4}\tinput1={X:0>4}\toutput={X:0>4}\r\n", .{
                    start_ip,
                    instruction,
                    input0,
                    input1,
                    output,
                });
            }
        } else {
            if (instruction.input0 == .immediate) self.ip +%= 2;
            if (instruction.input1 == .immediate) self.ip +%= 2;
        }
    }

    pub fn run(self: *Self) !void {
        while (true) {
            try self.executeSingle();
            self.count += 1;
        }
    }

    pub fn runBatch(self: *Self, count: u64) !void {
        var i: u64 = count;
        while (i > 0) {
            i -= 1;
            try self.executeSingle();
        }
    }

    pub const LoaderError = error{InvalidAddress};
    pub fn loadHexRecord(self: *Self, base: u32, data: []const u8) LoaderError!void {
        // std.debug.warn("load {}+{}: {X}\n", .{ base, data.len, data });
        for (data) |byte, offset| {
            const address = base + offset;
            switch (address) {
                0x0000...0x3FFF => |a| self.rom[a] = byte,
                0x6000...0x6FFF => |a| self.ram0[a - 0x6000] = byte,
                0x8000...0xFFFF => |a| self.ram1[a - 0x8000] = byte,
                else => return error.InvalidAddress,
            }
        }
    }
};
