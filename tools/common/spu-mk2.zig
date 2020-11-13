const std = @import("std");

pub const MemoryInterface = struct {
    const Self = @This();
    pub const Error = error{ UnalignedAccess, BusError };

    readByteFn: fn (self: *Self, address: u16) Error!u8,
    writeByteFn: fn (self: *Self, address: u16, value: u8) Error!void,
    readWordFn: fn (self: *Self, address: u16) Error!u16,
    writeWordFn: fn (self: *Self, address: u16, value: u16) Error!void,

    pub fn readByte(self: *Self, address: u16) !u8 {
        return self.readByteFn(self, address);
    }
    pub fn writeByte(self: *Self, address: u16, value: u8) !void {
        return self.writeByteFn(self, address, value);
    }
    pub fn readWord(self: *Self, address: u16) !u16 {
        return self.readWordFn(self, address);
    }
    pub fn writeWord(self: *Self, address: u16, value: u16) !void {
        return self.writeWordFn(self, address, value);
    }
};

pub const SpuMk2 = struct {
    const Self = @This();
    const Stage = enum {
        decode,
        execute,
        postprocess,
    };

    memory: *MemoryInterface,

    ip: u16,
    bp: u16,
    fr: FlagRegister,
    sp: u16,

    bus_addr: u16,
    stage: Stage,

    pub fn init(memory: *MemoryInterface) Self {
        return Self{
            .memory = memory,

            .ip = 0x0000,
            .fr = std.mem.zeroes(FlagRegister),
            .bp = undefined,
            .sp = undefined,

            .bus_addr = undefined,
            .stage = undefined,
        };
    }

    pub fn readByte(self: *Self, address: u16) !u8 {
        return self.memory.readByte(address);
    }

    pub fn writeByte(self: *Self, address: u16, value: u8) !void {
        return self.memory.writeByte(address, value);
    }

    pub fn readWord(self: *Self, address: u16) !u16 {
        if ((address & 1) != 0)
            return error.UnalignedAccess;
        return self.memory.readWord(address);
    }

    pub fn writeWord(self: *Self, address: u16, value: u16) !void {
        if ((address & 1) != 0)
            return error.UnalignedAccess;
        return self.memory.writeWord(address, value);
    }

    pub fn fetch(self: *Self) !u16 {
        const value = try self.readWord(self.ip);
        self.ip +%= 2;
        return value;
    }

    pub fn peek(self: *Self) !u16 {
        return try self.readWord(self.sp);
    }

    pub fn pop(self: *Self) !u16 {
        const value = try self.readWord(self.sp);
        self.sp +%= 2;
        return value;
    }

    pub fn push(self: *Self, value: u16) !void {
        self.sp -%= 2;
        try self.writeWord(self.sp, value);
    }

    pub fn executeSingle(self: *Self) !void {
        self.stage = .decode;

        const start_ip = self.ip;

        const instruction = @bitCast(Instruction, try self.fetch());

        if (instruction.reserved == 1) {
            switch (@bitCast(u16, instruction)) {
                //0x8000 => self.tracing = false,
                //0x8001 => self.tracing = true,
                //0x8002 => try @import("root").dumpState(self),
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
            // if (self.tracing) {
            //     try @import("root").dumpTrace(self, start_ip, instruction, input0, input1, output);
            // }
        } else {
            if (instruction.input0 == .immediate) self.ip +%= 2;
            if (instruction.input1 == .immediate) self.ip +%= 2;
        }
    }

    pub fn runBatch(self: *Self, count: u64) !void {
        var i: u64 = count;
        while (i > 0) {
            i -= 1;
            try self.executeSingle();
        }
    }
};

pub const ExecutionCondition = enum(u3) {
    always = 0,
    when_zero = 1,
    not_zero = 2,
    greater_zero = 3,
    less_than_zero = 4,
    greater_or_equal_zero = 5,
    less_or_equal_zero = 6,
    overflow = 7,
};

pub const InputBehaviour = enum(u2) {
    zero = 0,
    immediate = 1,
    peek = 2,
    pop = 3,
};

pub const OutputBehaviour = enum(u2) {
    discard = 0,
    push = 1,
    jump = 2,
    jump_relative = 3,
};

pub const Command = enum(u5) {
    copy = 0,
    ipget = 1,
    get = 2,
    set = 3,
    store8 = 4,
    store16 = 5,
    load8 = 6,
    load16 = 7,
    undefined0 = 8,
    undefined1 = 9,
    frget = 10,
    frset = 11,
    bpget = 12,
    bpset = 13,
    spget = 14,
    spset = 15,
    add = 16,
    sub = 17,
    mul = 18,
    div = 19,
    mod = 20,
    @"and" = 21,
    @"or" = 22,
    xor = 23,
    not = 24,
    signext = 25,
    rol = 26,
    ror = 27,
    bswap = 28,
    asr = 29,
    lsl = 30,
    lsr = 31,
};

pub const Instruction = packed struct {
    condition: ExecutionCondition,
    input0: InputBehaviour,
    input1: InputBehaviour,
    modify_flags: bool,
    output: OutputBehaviour,
    command: Command,
    reserved: u1 = 0,

    pub fn format(instr: Instruction, comptime fmt: []const u8, options: std.fmt.FormatOptions, out: anytype) !void {
        try out.writeAll(switch (instr.condition) {
            .always => "    ",
            .when_zero => "== 0",
            .not_zero => "!= 0",
            .greater_zero => " > 0",
            .less_than_zero => " < 0",
            .greater_or_equal_zero => ">= 0",
            .less_or_equal_zero => "<= 0",
            .overflow => "ovfl",
        });
        try out.writeAll(" ");
        try out.writeAll(switch (instr.input0) {
            .zero => "zero",
            .immediate => "imm ",
            .peek => "peek",
            .pop => "pop ",
        });
        try out.writeAll(" ");
        try out.writeAll(switch (instr.input1) {
            .zero => "zero",
            .immediate => "imm ",
            .peek => "peek",
            .pop => "pop ",
        });
        try out.writeAll(" ");
        try out.writeAll(switch (instr.command) {
            .copy => "copy     ",
            .ipget => "ipget    ",
            .get => "get      ",
            .set => "set      ",
            .store8 => "store8   ",
            .store16 => "store16  ",
            .load8 => "load8    ",
            .load16 => "load16   ",
            .undefined0 => "undefined",
            .undefined1 => "undefined",
            .frget => "frget    ",
            .frset => "frset    ",
            .bpget => "bpget    ",
            .bpset => "bpset    ",
            .spget => "spget    ",
            .spset => "spset    ",
            .add => "add      ",
            .sub => "sub      ",
            .mul => "mul      ",
            .div => "div      ",
            .mod => "mod      ",
            .@"and" => "and      ",
            .@"or" => "or       ",
            .xor => "xor      ",
            .not => "not      ",
            .signext => "signext  ",
            .rol => "rol      ",
            .ror => "ror      ",
            .bswap => "bswap    ",
            .asr => "asr      ",
            .lsl => "lsl      ",
            .lsr => "lsr      ",
        });
        try out.writeAll(" ");
        try out.writeAll(switch (instr.output) {
            .discard => "discard",
            .push => "push   ",
            .jump => "jmp    ",
            .jump_relative => "rjmp   ",
        });
        try out.writeAll(" ");
        try out.writeAll(if (instr.modify_flags)
            "+ flags"
        else
            "       ");
    }
};

pub const FlagRegister = packed struct {
    zero: bool,
    negative: bool,
    carry: bool,
    carry_enabled: bool,
    interrupt0_enabled: bool,
    interrupt1_enabled: bool,
    interrupt2_enabled: bool,
    interrupt3_enabled: bool,
    reserved: u8 = 0,
};
