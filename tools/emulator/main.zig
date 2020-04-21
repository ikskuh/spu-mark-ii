const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");

pub fn main() !u8 {
    const cli_args = try argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        @"entry-point": u16 = 0x0000,

        pub const shorthands = .{
            .h = "help",
            .e = "entry-point",
        };
    }, std.heap.page_allocator);
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len == 0) {
        try std.io.getStdOut().outStream().writeAll(
            \\ emulator [--help] initialization.hex […]
            \\ Emulates the Ashet Home Computer, based on the SPU Mark II.
            \\ Each file passed as an argument will be loaded into the memory
            \\ and provides an initialization for ROM and RAM.
            \\
            \\ -h, --help  Displays this help text.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else @as(u8, 1);
    }

    var emu = Emulator.init();

    const hexParseMode = ihex.ParseMode{ .pedantic = true };
    for (cli_args.positionals) |path| {
        var file = try std.fs.cwd().openFile(path, .{ .read = true, .write = false });
        defer file.close();

        // Emulator will always start at address 0x0000 or CLI given entry point.
        _ = try ihex.parseData(file.inStream(), hexParseMode, &emu, Emulator.LoaderError, Emulator.loadHexRecord);
    }

    emu.ip = cli_args.options.@"entry-point";

    const stdin = std.io.getStdIn();
    const termios_bak = if (std.builtin.os.tag == .linux) blk: {
        const original = try std.os.tcgetattr(stdin.handle);

        var modified_raw = original;

        const IGNBRK = 0o0000001;
        const BRKINT = 0o0000002;
        const PARMRK = 0o0000010;
        const ISTRIP = 0o0000040;
        const INLCR = 0o0000100;
        const IGNCR = 0o0000200;
        const ICRNL = 0o0000400;
        const IXON = 0o0002000;

        const OPOST = 0o0000001;

        const ECHO = 0o0000010;
        const ECHONL = 0o0000100;
        const ICANON = 0o0000002;
        const ISIG = 0o0000001;
        const IEXTEN = 0o0100000;

        const CSIZE = 0o0000060;
        const PARENB = 0o0000400;

        const CS8 = 0o0000060;

        // Note that this will also disable break signals!
        modified_raw.iflag &= ~@as(std.os.tcflag_t, IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
        modified_raw.oflag &= ~@as(std.os.tcflag_t, OPOST);
        modified_raw.lflag &= ~@as(std.os.tcflag_t, ISIG | ECHO | ECHONL | ICANON | IEXTEN);
        modified_raw.cflag &= ~@as(std.os.tcflag_t, CSIZE | PARENB);
        modified_raw.cflag |= CS8;

        try std.os.tcsetattr(stdin.handle, .NOW, modified_raw);

        break :blk original;
    } else {};

    defer if (std.builtin.os.tag == .linux) {
        std.os.tcsetattr(stdin.handle, .NOW, termios_bak) catch {
            std.debug.warn("Failed to reset stdin. Please call stty sane to get back a proper terminal experience!\n", .{});
        };
    };

    var timer = try std.time.Timer.start();
    emu.run() catch |err| {
        // reset terminal before outputting error messages
        if (std.builtin.os.tag == .linux) {
            try std.os.tcsetattr(stdin.handle, .NOW, termios_bak);
        }

        const time = timer.read();
        try std.io.getStdOut().outStream().print(
            "\n{}: IP={X:0>4} SP={X:0>4} BP={X:0>4} FR={X:0>4} BUS={X:0>4} STAGE={} TIME={}ns COUNT={} IPS={}\n",
            .{
                @errorName(err),
                emu.ip,
                emu.sp,
                emu.bp,
                @bitCast(u16, emu.fr),
                emu.bus_addr,
                @tagName(emu.stage),
                time,
                emu.count,
                std.time.second * emu.count / time,
            },
        );
        return err;
    };

    return 0;
}

pub const SerialEmulator = struct {
    pub fn read() !u16 {
        const stdin = std.io.getStdIn();
        if (std.builtin.os.tag == .linux) {
            var fds = [1]std.os.pollfd{
                .{
                    .fd = stdin.handle,
                    .events = std.os.POLLIN,
                    .revents = 0,
                },
            };
            _ = try std.os.poll(&fds, 1);
            if ((fds[0].revents & std.os.POLLIN) != 0) {
                const val = @as(u16, try stdin.inStream().readByte());
                if (val == 0x03) // CTRL_C
                    return error.UserBreak;
                return val;
            }
        }
        return 0xFFFF;
    }

    pub fn write(value: u16) !void {
        try std.io.getStdOut().outStream().print("{c}", .{@truncate(u8, value)});
    }
};

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
            0x4000...0x4FFF => @truncate(u8, try SerialEmulator.read()),
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
            0x4000...0x4FFF => try SerialEmulator.write(value),
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
            0x4000...0x4FFF => try SerialEmulator.read(),
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
            0x4000...0x4FFF => try SerialEmulator.write(value),
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
        const instruction = @bitCast(Instruction, try self.fetch());

        const execute = switch (instruction.condition) {
            .always => true,
            .when_zero => self.fr.zero,
            .not_zero => !self.fr.zero,
            .greater_zero => !self.fr.zero and !self.fr.negative,
            .less_than_zero => !self.fr.zero and self.fr.negative,
            .greater_or_equal_zero => self.fr.zero or !self.fr.negative,
            .less_or_equal_zero => self.fr.zero or self.fr.negative,
            else => return error.BadInstruction,
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
                .get => try self.readWord(self.bp + 2 *% input0),
                .set => blk: {
                    try self.writeWord(self.bp + 2 *% input0, input1);
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
                .add => input0 +% input1,
                .sub => input0 -% input1,
                .mul => input0 *% input1,
                .div => input0 / input1,
                .mod => input0 % input1,
                .@"and" => input0 & input1,
                .@"or" => input0 | input1,
                .xor => input0 ^ input1,
                .not => ~input0,
                .neg => ~input0 +% 1,
                .rol => (input0 << 1) | (input0 >> 15),
                .ror => (input0 >> 1) | (input0 << 15),
                .bswap => (input0 << 8) | (input0 >> 8),
                .asr => (input0 & 0x8000) | (input0 >> 1),
                .lsl => input0 << 1,
                .lsr => input0 >> 1,
                .undefined0, .undefined1 => return error.BadInstruction,
                else => return error.UnimplementedInstruction,
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
            // std.debug.warn(
            //     \\------------------------
            //     \\instr={}
            //     \\input0={}
            //     \\input1={}
            //     \\output={}
            //     \\
            // , .{ instruction, input0, input1, output });
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

    const LoaderError = error{InvalidAddress};
    fn loadHexRecord(self: *Self, base: u32, data: []const u8) LoaderError!void {
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

pub const ExecutionCondition = enum(u3) {
    always = 0,
    when_zero = 1,
    not_zero = 2,
    greater_zero = 3,
    less_than_zero = 4,
    greater_or_equal_zero = 5,
    less_or_equal_zero = 6,
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
    neg = 25,
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
};

pub const FlagRegister = packed struct {
    zero: bool,
    negative: bool,
    interrupt0_enabled: bool,
    interrupt1_enabled: bool,
    interrupt2_enabled: bool,
    interrupt3_enabled: bool,
    reserved: u10 = 0,
};
