const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");
const spu = @import("spu-mk2");
const common = @import("shared.zig");

extern "kernel32" fn SetConsoleMode(hConsoleHandle: std.os.windows.HANDLE, dwMode: std.os.windows.DWORD) callconv(.Stdcall) std.os.windows.BOOL;

pub fn dumpState(emu: *spu.SpuMk2(common.WasmDemoMachine)) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(
        "\r\nstate: IP={X:0>4} SP={X:0>4} BP={X:0>4} FR={X:0>4}\r\n",
        .{
            emu.ip,
            emu.sp,
            emu.bp,
            @bitCast(u16, emu.fr),
            // emu.bus_addr,
            // @tagName(emu.stage),
        },
    );

    try stdout.writeAll("stack:\n");

    var offset: i8 = -4;
    while (offset <= 4) : (offset += 1) {
        const msg: []const u8 = if (offset == 0) " <-" else ""; // workaround for tuple bug
        const addr = if (offset < 0) emu.sp -% @intCast(u8, -2 * offset) else emu.sp +% @intCast(u8, 2 * offset);
        const msg_2: []const u8 = if (addr == emu.bp) " (BASE)" else "";
        const value = emu.readWord(addr) catch @as(u16, 0xAAAA);
        try stdout.print("  {X:0>4}: [SP{:0>2}]={X:0>4}{s}{s}\r\n", .{
            addr,
            offset,
            value,
            msg,
            msg_2,
        });
    }
}

var termios_bak: std.os.termios = undefined;

var window: *c.SDL_Window = undefined;
var renderer: *c.SDL_Renderer = undefined;
var texture: *c.SDL_Texture = undefined;

var framebuffer: [128][256]u8 = undefined;

fn outputErrorMsg(emu: *spu.SpuMk2(common.WasmDemoMachine), err: anyerror) !u8 {
    const stdin = std.io.getStdIn();

    // reset terminal before outputting error messages
    if (std.builtin.os.tag == .linux) {
        try std.os.tcsetattr(stdin.handle, .NOW, termios_bak);
    }

    // const time = timer.read();

    try std.io.getStdOut().writer().print("\nerror: {s}\n", .{
        @errorName(err),
    });

    try dumpState(emu);

    switch (err) {
        error.BusError, error.UserBreak => return 1,
        else => return err,
    }
    unreachable;
}

pub fn main() !u8 {
    const cli_args = argsParser.parseForCurrentProcess(struct {
        help: bool = false,
        @"entry-point": u16 = 0x0000,
        trace: bool = false,

        pub const shorthands = .{
            .h = "help",
            .e = "entry-point",
        };
    }, std.heap.page_allocator, .print) catch return 1;
    defer cli_args.deinit();

    if (cli_args.options.help or cli_args.positionals.len == 0) {
        try std.io.getStdOut().writer().writeAll(
            \\emulator [--help] initialization.hex […]
            \\Emulates the Ashet Home Computer, based on the SPU Mark II.
            \\Each file passed as an argument will be loaded into the memory
            \\and provides an initialization for ROM and RAM.
            \\
            \\-h, --help  Displays this help text.
            \\
        );
        return if (cli_args.options.help) @as(u8, 0) else @as(u8, 1);
    }

    var debugger = Debugger{};

    var emu = spu.SpuMk2(common.WasmDemoMachine).init(.{});
    const memory = &emu.memory;

    if (cli_args.options.trace) {
        emu.debug_interface = &debugger.interface;
    }

    const hexParseMode = ihex.ParseMode{ .pedantic = true };
    for (cli_args.positionals) |path| {
        var file = try std.fs.cwd().openFile(path, .{ .read = true, .write = false });
        defer file.close();

        // Emulator will always start at address 0x0000 or CLI given entry point.
        _ = try ihex.parseData(file.reader(), hexParseMode, memory, common.WasmDemoMachine.LoaderError, common.WasmDemoMachine.loadHexRecord);
    }

    emu.ip = cli_args.options.@"entry-point";

    const stdin = std.io.getStdIn();
    if (std.builtin.os.tag == .linux) {
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
        _ = 0;
        _ = 0;
        _ = 0 | ISIG;
        modified_raw.iflag &= ~@as(std.os.tcflag_t, BRKINT | IGNBRK | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
        modified_raw.oflag &= ~@as(std.os.tcflag_t, OPOST);
        modified_raw.lflag &= ~@as(std.os.tcflag_t, ECHO | ECHONL | ICANON | IEXTEN);
        modified_raw.cflag &= ~@as(std.os.tcflag_t, CSIZE | PARENB);
        modified_raw.cflag |= CS8;

        try std.os.tcsetattr(stdin.handle, .NOW, modified_raw);

        termios_bak = original;
    }

    defer if (std.builtin.os.tag == .linux) {
        std.os.tcsetattr(stdin.handle, .NOW, termios_bak) catch {
            std.debug.warn("Failed to reset stdin. Please call stty sane to get back a proper terminal experience!\n", .{});
        };
    };

    if (std.builtin.os.tag == .windows) {
        if (SetConsoleMode(stdin.handle, 0) == 0)
            return error.FailedToSetConsole;
    }

    // defer std.debug.warn("Executed {} instructions!\n", .{emu.count});

    while (true) {
        emu.runBatch(10_000) catch |err| switch (err) {
            error.CpuHalted => return 0,
            else => |e| return try outputErrorMsg(&emu, e),
        };
    }

    return 0;
}

const Debugger = struct {
    interface: spu.DebugInterface = .{
        .traceInstructionFn = traceInstruction,
        .traceAddressFn = traceAddress,
    },

    fn traceInstruction(interface: *spu.DebugInterface, ip: u16, instruction: spu.Instruction, input0: u16, input1: u16, output: u16) void {
        const self = @fieldParentPtr(Debugger, "interface", interface);
        _ = self;

        const stdout = std.io.getStdOut().writer();
        stdout.print("offset={X:0>4} instr={}\tinput0={X:0>4}\tinput1={X:0>4}\toutput={X:0>4}\r\n", .{
            ip,
            instruction,
            input0,
            input1,
            output,
        }) catch {};
    }
    fn traceAddress(interface: *spu.DebugInterface, virt: u16) spu.DebugInterface.TraceError!void {
        const self = @fieldParentPtr(Debugger, "interface", interface);

        _ = self;
        _ = virt;
        //
    }
};

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
            _ = try std.os.poll(&fds, 0);
            if ((fds[0].revents & std.os.POLLIN) != 0) {
                const val = @as(u16, try stdin.reader().readByte());
                if (val == 0x03) // CTRL_C
                    return error.UserBreak;
                return val;
            }
        }
        if (std.builtin.os.tag == .windows) {
            std.os.windows.WaitForSingleObject(stdin.handle, 0) catch |err| switch (err) {
                error.WaitTimeOut => return 0xFFFF,
                else => return err,
            };
            const val = @as(u16, try stdin.reader().readByte());
            if (val == 0x03) // CTRL_C
                return error.UserBreak;
            return val;
        }
        return 0xFFFF;
    }

    pub fn write(value: u16) !void {
        try std.io.getStdOut().writer().print("{c}", .{@truncate(u8, value)});
        // std.time.sleep(50 * std.time.millisecond);
    }
};
