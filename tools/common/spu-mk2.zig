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

pub const TracingInterface = struct {
    const Self = @This();

    traceInstructionFn: fn (self: *Self, ip: u16, instruction: Instruction, input0: u16, input1: u16, output: u16) void,

    pub fn traceInstruction(self: *Self, ip: u16, instruction: Instruction, input0: u16, input1: u16, output: u16) void {
        self.traceInstructionFn(self, ip, instruction, input0, input1, output);
    }
};

pub const SpuMk2 = struct {
    const Self = @This();

    memory: *MemoryInterface,
    tracing: ?*TracingInterface,
    trace_enabled: bool,

    ip: u16,
    bp: u16,
    fr: FlagRegister,
    sp: u16,

    pub fn init(memory: *MemoryInterface) Self {
        return Self{
            .memory = memory,

            .tracing = null,
            .trace_enabled = false,

            .ip = 0x0000,
            .fr = std.mem.zeroes(FlagRegister),
            .bp = undefined,
            .sp = undefined,
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
        const start_ip = self.ip;

        const instruction = @bitCast(Instruction, try self.fetch());

        if (instruction.reserved == 1) {
            switch (@bitCast(u16, instruction)) {
                0x8000 => self.trace_enabled = false,
                0x8001 => self.trace_enabled = true,
                //0x8002 => try @import("root").dumpState(self),
                else => return error.BadInstruction,
            }
            return;
        }

        const execute = switch (instruction.condition) {
            .always => true,
            .when_zero => self.fr.bits.zero,
            .not_zero => !self.fr.bits.zero,
            .greater_zero => !self.fr.bits.zero and !self.fr.bits.negative,
            .less_than_zero => !self.fr.bits.zero and self.fr.bits.negative,
            .greater_or_equal_zero => self.fr.bits.zero or !self.fr.bits.negative,
            .less_or_equal_zero => self.fr.bits.zero or self.fr.bits.negative,
            .overflow => self.fr.bits.carry,
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

            const output = switch (instruction.command) {
                .copy => input0,
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
                .frget => self.fr.int & ~input1,
                .frset => blk: {
                    const previous = self.fr.int;
                    self.fr.int = (self.fr.int & input1) | (input0 & ~input1);
                    break :blk previous;
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
                    self.fr.bits.carry = @addWithOverflow(u16, input0, input1, &result);
                    break :blk result;
                },
                .sub => blk: {
                    var result: u16 = undefined;
                    self.fr.bits.carry = @subWithOverflow(u16, input0, input1, &result);
                    break :blk result;
                },
                .mul => blk: {
                    var result: u16 = undefined;
                    self.fr.bits.carry = @mulWithOverflow(u16, input0, input1, &result);
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
                .cpuid => 0,
                .halt => @panic("not implemented yet!"),
                .setip => blk: {
                    const out = self.ip;
                    self.ip = input0;
                    self.fr.int |= input1;
                    break :blk out;
                },
                .addip => blk: {
                    const out = self.ip;
                    self.ip += input0;
                    self.fr.int |= input1;
                    break :blk out;
                },
                .intr => @panic("not implemented yet!"),
                _ => return error.BadInstruction,
            };

            switch (instruction.output) {
                .discard => {},
                .push => try self.push(output),
            }
            if (instruction.modify_flags) {
                self.fr.bits.negative = (output & 0x8000) != 0;
                self.fr.bits.zero = (output == 0x0000);
            }

            if (self.tracing) |intf| {
                if (self.trace_enabled)
                    intf.traceInstruction(start_ip, instruction, input0, input1, output);
            }
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

pub const OutputBehaviour = enum(u1) {
    discard = 0,
    push = 1,
};

pub const Command = enum(u6) {
    copy = 0b000000,
    get = 0b000010,
    set = 0b000011,
    store8 = 0b000100,
    store16 = 0b000101,
    load8 = 0b000110,
    load16 = 0b000111,
    cpuid = 0b001000,
    halt = 0b001001,
    frget = 0b001010,
    frset = 0b001011,
    bpget = 0b001100,
    bpset = 0b001101,
    spget = 0b001110,
    spset = 0b001111,
    add = 0b010000,
    sub = 0b010001,
    mul = 0b010010,
    div = 0b010011,
    mod = 0b010100,
    @"and" = 0b010101,
    @"or" = 0b010110,
    xor = 0b010111,
    not = 0b011000,
    signext = 0b011001,
    rol = 0b011010,
    ror = 0b011011,
    bswap = 0b011100,
    asr = 0b011101,
    lsl = 0b011110,
    lsr = 0b011111,
    setip = 0b100000,
    addip = 0b100001,
    intr = 0b100010,
    _,
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
        _ = options;
        _ = fmt;
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

        const tag = @tagName(instr.command);
        var tagstr = [_]u8{' '} ** 9;
        std.mem.copy(u8, &tagstr, tag);

        try out.writeAll(&tagstr);
        try out.writeAll(" ");
        try out.writeAll(switch (instr.output) {
            .discard => "discard",
            .push => "push   ",
        });
        try out.writeAll(" ");
        try out.writeAll(if (instr.modify_flags)
            "+ flags"
        else
            "       ");
    }
};

pub const FlagRegister = extern union {
    int: u16,
    bits: packed struct {
        zero: bool,
        negative: bool,
        carry: bool,
        carry_enabled: bool,
        interrupt0_enabled: bool,
        interrupt1_enabled: bool,
        interrupt2_enabled: bool,
        interrupt3_enabled: bool,
        reserved: u8 = 0,
    },
};
