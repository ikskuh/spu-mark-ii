const std = @import("std");

const sdl = @import("sdl2");
const spu = @import("spu-mk2");
const args = @import("args");

const CliArgs = struct {
    const SerialPort = enum {
        none,
        stdio,
    };

    help: bool = false,
    serial1: SerialPort = .none,
    serial2: SerialPort = .none,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const global_allocator = &gpa.allocator;

var debug_tracer = spu.TracingInterface{
    .traceInstructionFn = struct {
        fn traceInstruction(intf: *spu.TracingInterface, ip: u16, instruction: spu.Instruction, input0: u16, input1: u16, output: u16) void {
            std.debug.warn("IP={X:0>4} I0={X:0>4} I1={X:0>4} OUT={X:0>4} OP=[{}]\n", .{
                ip,
                input0,
                input1,
                output,
                instruction,
            });
        }
    }.traceInstruction,
};

pub fn main() !u8 {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();

    const cli = try args.parseForCurrentProcess(CliArgs, global_allocator);
    defer cli.deinit();

    if (cli.options.help) {
        try usage(stderr);
        return 0;
    }

    if (cli.positionals.len == 0) {
        try usage(stderr);
        return 1;
    }

    try sdl.init(.{
        .video = true,
        .events = true,
    });
    defer sdl.quit();

    var window = try sdl.createWindow(
        "Ashet Home Computer",
        .centered,
        .centered,
        640,
        480,
        .{},
    );
    defer window.destroy();

    var renderer = try sdl.createRenderer(window, null, .{
        .accelerated = true,
        .present_vsync = true,
    });
    defer renderer.destroy();

    var render_target = try sdl.createTexture(
        renderer,
        .bgr565,
        .streaming,
        640,
        480,
    );

    const ashet: *Ashet = try std.heap.page_allocator.create(Ashet);
    defer std.heap.page_allocator.destroy(ashet);

    Ashet.init(ashet);
    defer ashet.deinit();

    var success = true; //  we require at least one boot image file

    for (cli.positionals) |file, i| {
        const ext = fileExtension(file) orelse {
            try stderr.print("{} is missing a file extension, cannot autodetect the file type!\n", .{file});
            success = false;
            continue;
        };

        if (std.mem.eql(u8, ext, "bin")) {
            _ = try std.fs.cwd().readFile(file, &ashet.rom_buffer);
        } else if (std.mem.eql(u8, ext, "hex")) {
            try stderr.writeAll("ihex loading is not implemented yet!\n");
            success = false;
        } else {
            try stderr.print("{} is not a supported BIOS format!\n", .{ext});
            success = false;
        }
    }

    if (!success) {
        return 1;
    }

    main_loop: while (true) {
        while (sdl.pollEvent()) |event| {
            switch (event) {
                .quit => break :main_loop,
                else => {},
            }
        }

        // Step the emulation

        // const timer = try std.time.Timer.start();

        try ashet.runFor(16 * std.time.ns_per_ms);

        // const time = @intToFloat(f64, timer.read()) / std.time.ns_per_ms;

        // std.debug.warn("emulation time: {d}ms\n", .{time});

        // Fetch the VGA screen output
        var fb: [480][640]VGA.RGB = undefined;
        try ashet.vga.render(&fb);

        try render_target.update(std.mem.sliceAsBytes(&fb), 640 * @sizeOf(VGA.RGB), null);

        try renderer.copy(render_target, null, null);

        renderer.present();
    }

    return 0;
}

fn usage(out: anytype) !void {
    try out.writeAll(
        \\ashet [BIOS.bin]
        \\--help                             Displays this help message
        \\--serial1, --serial2 [none|stdio]  Configures the serial port 1 or 2.
        \\                                   none:  The serial port has no I/O capabilities.
        \\                                   stdio: The serial port is emulated via stdin and stdout.
        \\
    );
}

const BusDevice = struct {
    const Self = @This();

    const UnmappedImpl = struct {
        fn read8(p: *Self, address: u24) !u8 {
            return error.BusError;
        }
        fn read16(p: *Self, address: u24) !u16 {
            return error.BusError;
        }

        fn write8(p: *Self, address: u24, value: u8) !void {}
        fn write16(p: *Self, address: u24, value: u16) !void {}
    };

    var unmapped_stor = Self{
        .read8Fn = UnmappedImpl.read8,
        .read16Fn = UnmappedImpl.read16,
        .write8Fn = UnmappedImpl.write8,
        .write16Fn = UnmappedImpl.write16,
    };
    pub const unmapped: *Self = &unmapped_stor;

    pub const Error = error{
        BusError,
        UnalignedAccess,
    };

    read8Fn: fn (*Self, u24) Error!u8,
    read16Fn: fn (*Self, u24) Error!u16,

    write8Fn: fn (*Self, u24, u8) Error!void,
    write16Fn: fn (*Self, u24, u16) Error!void,

    pub fn read8(self: *Self, address: u24) !u8 {
        return self.read8Fn(self, address);
    }

    pub fn write8(self: *Self, address: u24, value: u8) !void {
        return self.write8Fn(self, address, value);
    }

    pub fn read16(self: *Self, address: u24) !u16 {
        if (!isWordAlignedAddress(address))
            return error.UnalignedAccess;
        return self.read16Fn(self, address);
    }

    pub fn write16(self: *Self, address: u24, value: u16) !void {
        if (!isWordAlignedAddress(address))
            return error.UnalignedAccess;
        return self.write16Fn(self, address, value);
    }

    fn read16With8(self: *Self, address: u24) !u16 {
        return (@as(u16, try self.read8(address + 0)) << 0) |
            (@as(u16, try self.read8(address + 1)) << 8);
    }

    fn write16With8(self: *Self, address: u24, value: u16) !void {
        try self.write8(address + 0, @truncate(u8, value >> 0));
        try self.write8(address + 1, @truncate(u8, value >> 8));
    }

    fn read8With16(self: *Self, address: u24) !u8 {
        const val = try self.read16(address & 0xFFFE);
        return if ((address & 1) == 1)
            @truncate(u8, val >> 8)
        else
            @truncate(u8, val >> 0);
    }

    fn write8With16(self: *Self, address: u24, value: u8) !void {
        const aligned_address = address & 0xFFFE;
        const current_val = try self.read16(aligned_address);
        try self.write16(aligned_address, if ((address & 1) == 1)
            (@as(u16, value) << 8) & (current_val & 0x00FF)
        else
            (@as(u16, value) << 0) & (current_val & 0xFF00));
    }
};

const Ashet = struct {
    const Self = @This();

    // System configuration
    cpu_clock: u64 = 10_000_000, // instructions per second

    // Memory buffers
    rom_buffer: [8388608]u8 = undefined, // 8 MB Flash
    ram_buffer: [524288]u8 = undefined, // 512 kB RAM

    // Memory interface
    bus: Bus,
    mmu: MMU,
    cpu: spu.SpuMk2,

    // Memory mapped parts
    ram: Memory,
    rom: Memory,
    vga: VGA,
    uart0: UART,
    uart1: UART,
    sdio0: SDIO,
    sdio1: SDIO,

    // Emulation state

    /// emulation time in nanoseconds
    emulation_time: u64 = 0,
    real_time: u64 = 0,

    // After a call to init, `self` must not be moved anymore!
    pub fn init(self: *Self) void {
        self.* = Self{
            .cpu = spu.SpuMk2.init(&self.mmu.interface),

            .bus = Bus{},
            .mmu = MMU{
                .bus = &self.bus,
            },

            .rom = Memory{ .data = &self.rom_buffer, .read_only = true },
            .ram = Memory{ .data = &self.ram_buffer, .read_only = false },
            .vga = VGA{
                .bus = &self.bus,
                .framebuffer_address = 0x000000,
            },
            .uart0 = UART{},
            .uart1 = UART{},
            .sdio0 = SDIO{ .bus = &self.bus },
            .sdio1 = SDIO{ .bus = &self.bus },
        };

        self.bus.mapRange(0x000000, 0x7FFFFF, &self.rom.bus_device);
        self.bus.mapRange(0x800000, 0xFFFFFF, &self.ram.bus_device);

        self.bus.mapAddress(0x7F0000, &self.mmu.bus_device);
        // - `0x7F1***`: (*Peripherial*) IRQ Controller
        self.bus.mapAddress(0x7F2000, &self.uart0.bus_device);
        self.bus.mapAddress(0x7F3000, &self.uart1.bus_device);
        // - `0x7F4***`: (*Peripherial*) PS/2'1 (Keyboar
        // - `0x7F5***`: (*Peripherial*) PS/2'2 (Mouse)
        self.bus.mapAddress(0x7F6000, &self.sdio0.bus_device);
        self.bus.mapAddress(0x7F7000, &self.sdio1.bus_device);
        // - `0x7F8***`: (*Peripherial*) Timer + RTC
        // - `0x7F9***`: (*Peripherial*) IrDA Interface
        // - `0x7FA***`: (*Peripherial*) Joystick Interf
        // - `0x7FB***`: (*Peripherial*) PCM Audio Contr
        // - `0x7FC***`: (*Peripherial*) DMA Control/Status
        self.bus.mapAddress(0x7FD000, &self.vga.bus_device_control);
        self.bus.mapAddress(0x7FE000, &self.vga.bus_device_palette);
        // - `0x7FF***`: (*Peripherial*) VGA Sprite Data

        // MMU is by-default in an identity mapping, so we need to map the MMU into the visible range.
        // In this case, we map the MMU into the last page of memory space
        self.mmu.page_config[0xF].physical_address = 0x7F0;

        self.cpu.tracing = &debug_tracer;
    }

    pub fn deinit(self: *Self) void {
        self.* = undefined;
    }

    /// Runs the emulation for the given amount of nanoseconds
    pub fn runFor(self: *Self, ns: u64) !void {
        const granularity = 1 * std.time.ns_per_us; // Run with 1µs steps

        self.real_time += ns;

        // this has a minimal error per clock, but we accept this
        const ns_per_cycle = std.time.ns_per_s / self.cpu_clock;
        const cycles_per_step = granularity / ns_per_cycle;

        while (self.emulation_time < self.real_time) : (self.emulation_time += granularity) {

            // TODO: Process inputs from UART1, PS/2, IrDA

            // Now, run the CPU
            self.cpu.runBatch(cycles_per_step) catch |err| {
                self.bus.enable_debug_msg = false;
                defer self.bus.enable_debug_msg = true;

                std.debug.print("CPU crashed at {X:0>4}:\n", .{
                    self.cpu.ip,
                });

                std.debug.print("   IP={X:0>4} SP={X:0>4} BP={X:0>4} FR={X:0>4}\n", .{
                    self.cpu.ip,
                    self.cpu.sp,
                    self.cpu.bp,
                    @bitCast(u16, self.cpu.fr),
                });

                var stack_ptr: u16 = self.cpu.sp -% 8;
                while (stack_ptr != self.cpu.sp +% 10) : (stack_ptr +%= 2) {
                    const value = self.mmu.interface.readWord(stack_ptr) catch null;
                    const indicator = if (stack_ptr == self.cpu.sp)
                        "-->"
                    else
                        "   ";
                    if (value) |val| {
                        std.debug.print("{}{X:0>4}: {X:0>4}\n", .{
                            indicator,
                            stack_ptr,
                            value,
                        });
                    } else {
                        std.debug.print("{}{X:0>4}: ????\n", .{
                            indicator,
                            stack_ptr,
                        });
                    }
                }

                return err;
            };

            // TODO: Process outputs from UART1, PS/2, IrDA

            while (self.uart0.output.readItem()) |item| {
                std.debug.print("UART0: {X:0>2} {c}\n", .{ item, item });
            }

            while (self.uart1.output.readItem()) |item| {
                std.debug.print("UART1: {X:0>2} {c}\n", .{ item, item });
            }
        }
    }
};

const Bus = struct {
    const Self = @This();

    devices: [4096]*BusDevice = [1]*BusDevice{&BusDevice.unmapped_stor} ** 4096,
    enable_debug_msg: bool = true,

    pub fn mapAddress(self: *Self, address: u24, device: *BusDevice) void {
        std.debug.assert(std.mem.isAligned(address, 0x1000));
        self.devices[address >> 12] = device;
    }

    pub fn unmapAddress(self: *Self, address: u24) void {
        self.mapAddress(address, BusDevice.unmapped);
    }

    pub fn mapRange(self: *Self, start: u24, end: u24, device: *BusDevice) void {
        var i = start;
        while (i < end) {
            self.mapAddress(i, device);

            if (@addWithOverflow(u24, i, 0x1000, &i))
                break;
        }
    }

    pub fn unmapRange(self: *Self, start: u24, end: u24) void {
        self.mapRange(start, end, BusDevice.unmapped);
    }

    fn deviceAt(self: *Self, address: u24) *BusDevice {
        return self.devices[address >> 12];
    }

    const BusAccess = enum { read, write };
    const AccessSize = enum { word, byte };
    fn logError(self: Self, err: BusDevice.Error, address: u24, access: BusAccess, size: AccessSize) BusDevice.Error {
        if (!self.enable_debug_msg)
            return err;
        // workaround for https://github.com/ziglang/zig/issues/7097
        const access_msg: []const u8 = switch (access) {
            .read => switch (size) {
                .byte => "reading byte from",
                .word => "reading word from",
            },
            .write => switch (size) {
                .byte => "writing byte to",
                .word => "writing word to",
            },
        };
        std.debug.print("{} when {} {X:0>6}\n", .{
            @errorName(err),
            access_msg,
            address,
        });
        return err;
    }

    pub fn read8(self: *Self, address: u24) !u8 {
        return self.deviceAt(address).read8(address) catch |err| self.logError(err, address, .read, .byte);
    }

    pub fn write8(self: *Self, address: u24, value: u8) !void {
        return self.deviceAt(address).write8(address, value) catch |err| self.logError(err, address, .write, .byte);
    }

    pub fn read16(self: *Self, address: u24) !u16 {
        return self.deviceAt(address).read16(address) catch |err| self.logError(err, address, .read, .word);
    }

    pub fn write16(self: *Self, address: u24, value: u16) !void {
        return self.deviceAt(address).write16(address, value) catch |err| self.logError(err, address, .write, .word);
    }
};

const Memory = struct {
    const Self = @This();

    data: []u8,
    read_only: bool,

    bus_device: BusDevice = BusDevice{
        .read16Fn = BusDevice.read16With8,
        .write16Fn = BusDevice.write16With8,

        .read8Fn = read8,
        .write8Fn = write8,
    },

    fn read8(busdev: *BusDevice, address: u24) !u8 {
        const mem = @fieldParentPtr(Self, "bus_device", busdev);
        const limit = std.math.ceilPowerOfTwo(usize, mem.data.len) catch unreachable;
        const offset = address & (limit - 1);

        return if (offset < mem.data.len)
            mem.data[offset]
        else
            return error.BusError;
    }

    fn write8(busdev: *BusDevice, address: u24, value: u8) !void {
        const mem = @fieldParentPtr(Self, "bus_device", busdev);
        if (mem.read_only)
            return error.BusError;

        const limit = std.math.ceilPowerOfTwo(usize, mem.data.len) catch unreachable;
        const offset = address & (limit - 1);

        if (offset < mem.data.len) {
            mem.data[offset] = value;
        } else {
            return error.BusError;
        }
    }
};

const VGA = struct {
    const Self = @This();
    const RGB = packed struct {
        r: u5,
        g: u6,
        b: u5,

        fn init(r: u8, g: u8, b: u8) RGB {
            return RGB{
                .r = @truncate(u5, r >> 3),
                .g = @truncate(u6, g >> 2),
                .b = @truncate(u5, b >> 3),
            };
        }
    };

    bus_device_palette: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = paletteRead16,
        .write16Fn = paletteWrite16,
    },
    bus_device_control: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = registerRead16,
        .write16Fn = registerWrite16,
    },

    palette: [256]RGB = init: {
        var pal: [256]RGB = undefined;
        var i: usize = 0;
        while (i < 256) : (i += 1) {
            pal[i] = RGB.init(
                @truncate(u8, i),
                @truncate(u8, i),
                @truncate(u8, i),
            );
        }
        break :init pal;
    },

    bus: *Bus,

    border_color: VGA.RGB = VGA.RGB.init(0x30, 0x34, 0x6d),
    framebuffer_address: u32 = 0x000000,
    framebuffer_stride: u32 = 0x000100, // default stride is a fully linear framebuffer

    /// Writes out the VGA image to a framebuffer
    pub fn render(self: Self, frame_buffer: *[480][640]VGA.RGB) !void {
        for (frame_buffer) |*row, y| {
            for (row) |*pix, x| {
                pix.* = self.border_color;
            }
        }

        {
            var row_offset = @truncate(u24, self.framebuffer_address);

            const dx = (640 - 256 * 2) / 2;
            const dy = (480 - 128 * 2) / 2;

            var y: usize = 0;
            while (y < 128) : (y += 1) {
                var offset = row_offset;
                var x: usize = 0;
                while (x < 256) : (x += 1) {
                    const pixel_index = try self.bus.read8(offset);
                    const low = self.palette[pixel_index];

                    frame_buffer[dy + 2 * y + 0][dx + 2 * x + 0] = low;
                    frame_buffer[dy + 2 * y + 1][dx + 2 * x + 0] = low;
                    frame_buffer[dy + 2 * y + 0][dx + 2 * x + 1] = low;
                    frame_buffer[dy + 2 * y + 1][dx + 2 * x + 1] = low;

                    offset +%= 1; // might overflow
                }
                row_offset +%= @truncate(u24, self.framebuffer_stride); // might overflow
            }
        }

        const H = struct {
            fn printHexDigit(fb: *[480][640]VGA.RGB, x: usize, y: usize, comptime T: type, number: T, color: RGB) void {
                const digits = (@bitSizeOf(T) + 3) / 4;

                var left: usize = 0;

                var digit: usize = digits;
                while (digit > 0) {
                    digit -= 1;

                    const glyph = hexfont_8x8[(number >> @intCast(u4, 4 * digit)) & 0xF];

                    var dy: usize = 0;
                    while (dy < 7) : (dy += 1) {
                        comptime var dx = 0;
                        inline while (dx < 5) : (dx += 1) {
                            if ((glyph[dy] & (0x10 >> dx)) != 0) {
                                fb[y + 2 * dy + 0][left + x + 2 * dx + 0] = color;
                                fb[y + 2 * dy + 1][left + x + 2 * dx + 0] = color;
                                fb[y + 2 * dy + 0][left + x + 2 * dx + 1] = color;
                                fb[y + 2 * dy + 1][left + x + 2 * dx + 1] = color;
                            }
                        }
                    }

                    left += 12;
                }
            }
        };
        //  TODO: this should be dependent on a hardware switch or register value
        if (true) {
            const ashet = @fieldParentPtr(Ashet, "vga", &self);

            const color = RGB.init(0xFF, 0x00, 0x00);

            H.printHexDigit(frame_buffer, 16, 16, u16, ashet.cpu.ip, color);
            H.printHexDigit(frame_buffer, 16, 32, u16, ashet.cpu.sp, color);
            H.printHexDigit(frame_buffer, 16, 48, u16, ashet.cpu.bp, color);
            H.printHexDigit(frame_buffer, 16, 64, u16, @bitCast(u16, ashet.cpu.fr), color);

            for (ashet.mmu.page_config) |cfg, i| {
                H.printHexDigit(frame_buffer, 8, 112 + 16 * i, u16, @bitCast(u16, cfg), color);
            }
        }
    }

    fn registerRead16(busdev: *BusDevice, address: u24) !u16 {
        const vga = @fieldParentPtr(Self, "bus_device_control", busdev);
        return switch ((address & 0x7FF) >> 1) {
            0 => @truncate(u16, vga.framebuffer_address),
            1 => @truncate(u16, vga.framebuffer_address >> 16),
            2 => @truncate(u16, vga.framebuffer_stride),
            3 => @truncate(u16, vga.framebuffer_stride >> 16),
            4 => @bitCast(u16, vga.border_color),
            else => return error.BusError,
        };
    }

    fn registerWrite16(busdev: *BusDevice, address: u24, value: u16) !void {
        const vga = @fieldParentPtr(Self, "bus_device_control", busdev);
        switch ((address & 0x7FF) >> 1) {
            0 => vga.framebuffer_address = (vga.framebuffer_address & 0xFFFF0000) | value,
            1 => vga.framebuffer_address = (vga.framebuffer_address & 0x0000FFFF) | (@as(u32, value) << 16),
            2 => vga.framebuffer_stride = (vga.framebuffer_stride & 0xFFFF0000) | value,
            3 => vga.framebuffer_stride = (vga.framebuffer_stride & 0x0000FFFF) | (@as(u32, value) << 16),
            4 => vga.border_color = @bitCast(VGA.RGB, value),
            else => return error.BusError,
        }
    }

    fn paletteRead16(busdev: *BusDevice, address: u24) !u16 {
        const vga = @fieldParentPtr(Self, "bus_device_palette", busdev);
        return @bitCast(u16, vga.palette[(address >> 1) & 0xFF]);
    }

    fn paletteWrite16(busdev: *BusDevice, address: u24, value: u16) !void {
        const vga = @fieldParentPtr(Self, "bus_device_palette", busdev);
        vga.palette[(address >> 1) & 0xFF] = @bitCast(RGB, value);
    }
};

const MMU = struct {
    const Self = @This();

    const Register = packed struct {
        enabled: bool = true,
        write_protected: bool = false,
        caching_enabled: bool = false,
        reserved: u1 = 0,
        physical_address: u12,
    };

    page_config: [16]Register = [16]Register{
        Register{ .physical_address = 0x000 },
        Register{ .physical_address = 0x001 },
        Register{ .physical_address = 0x002 },
        Register{ .physical_address = 0x003 },
        Register{ .physical_address = 0x004 },
        Register{ .physical_address = 0x005 },
        Register{ .physical_address = 0x006 },
        Register{ .physical_address = 0x007 },
        Register{ .physical_address = 0x008 },
        Register{ .physical_address = 0x009 },
        Register{ .physical_address = 0x00A },
        Register{ .physical_address = 0x00B },
        Register{ .physical_address = 0x00C },
        Register{ .physical_address = 0x00D },
        Register{ .physical_address = 0x00E },
        Register{ .physical_address = 0x00F },
    },

    page_fault_register: u16 = 0,
    write_fault_register: u16 = 0,

    /// The bus device that allows configuring the MMU
    bus_device: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = registerRead16,
        .write16Fn = registerWrite16,
    },

    /// The memory interface for the CPU
    interface: spu.MemoryInterface = spu.MemoryInterface{
        .readByteFn = memReadByte,
        .writeByteFn = memWriteByte,
        .readWordFn = memReadWord,
        .writeWordFn = memWriteWord,
    },

    /// The bus that is managed by the MMU
    bus: *Bus,

    const TranslateResult = struct {
        address: u24,
        config: Register,
    };
    fn translateAddress(self: Self, virtual_address: u16) TranslateResult {
        const page = virtual_address >> 12;
        const mapping = self.page_config[page];

        return TranslateResult{
            .address = (@as(u24, mapping.physical_address) << 12) | @as(u24, virtual_address & 0x0FFF),
            .config = mapping,
        };
    }

    const Access = enum { read, write };
    fn accessAddress(self: Self, virtual_address: u16, access: Access) !u24 {
        const physical_address = self.translateAddress(virtual_address);
        if (!physical_address.config.enabled)
            return error.BusError;
        if (physical_address.config.write_protected and access != .read)
            return error.BusError;
        return physical_address.address;
    }

    fn memReadByte(interface: *spu.MemoryInterface, address: u16) spu.MemoryInterface.Error!u8 {
        const self = @fieldParentPtr(Self, "interface", interface);
        return self.bus.read8(
            try self.accessAddress(address, .read),
        );
    }

    fn memWriteByte(interface: *spu.MemoryInterface, address: u16, value: u8) spu.MemoryInterface.Error!void {
        const self = @fieldParentPtr(Self, "interface", interface);
        return self.bus.write8(
            try self.accessAddress(address, .write),
            value,
        );
    }

    fn memReadWord(interface: *spu.MemoryInterface, address: u16) spu.MemoryInterface.Error!u16 {
        const self = @fieldParentPtr(Self, "interface", interface);
        return self.bus.read16(
            try self.accessAddress(address, .read),
        );
    }

    fn memWriteWord(interface: *spu.MemoryInterface, address: u16, value: u16) spu.MemoryInterface.Error!void {
        const self = @fieldParentPtr(Self, "interface", interface);
        return self.bus.write16(
            try self.accessAddress(address, .write),
            value,
        );
    }

    fn registerRead16(busdev: *BusDevice, address: u24) !u16 {
        const mmu = @fieldParentPtr(Self, "bus_device", busdev);
        const register = (address & 0x7FF) >> 1;
        return switch (register) {
            0x000...0x00F => @bitCast(u16, mmu.page_config[register]),
            0x010 => mmu.page_fault_register,
            0x011 => mmu.write_fault_register,
            else => return error.BusError,
        };
    }

    fn registerWrite16(busdev: *BusDevice, address: u24, value: u16) !void {
        const mmu = @fieldParentPtr(Self, "bus_device", busdev);
        const register = (address & 0x7FF) >> 1;
        switch (register) {
            0x000...0x00F => mmu.page_config[register] = @bitCast(Register, value),
            0x010 => mmu.page_fault_register = value,
            0x011 => mmu.write_fault_register = value,
            else => return error.BusError,
        }
    }
};

const UART = struct {
    const Self = @This();
    const Fifo = std.fifo.LinearFifo(u8, .{ .Static = 16 });

    bus_device: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = read16,
        .write16Fn = write16,
    },

    input: Fifo = Fifo.init(),
    output: Fifo = Fifo.init(),

    fn read16(busdev: *BusDevice, address: u24) BusDevice.Error!u16 {
        const uart = @fieldParentPtr(Self, "bus_device", busdev);
        return switch ((address & 0x7FF) >> 1) {
            0 => if (uart.input.readItem()) |byte|
                @as(u16, byte)
            else
                0xFFFF,
            1 => blk: {
                var status: u16 = 0;

                if (uart.input.readableLength() == 0)
                    status |= (1 << 0); // Receive Fifo Empty

                if (uart.output.writableLength() == uart.output.buf.len)
                    status |= (1 << 1); // Send Fifo Empty

                if (uart.input.readableLength() == uart.input.buf.len)
                    status |= (1 << 2); // Receive Fifo Full

                if (uart.output.writableLength() == 0)
                    status |= (1 << 3); // Send Fifo Full

                // no frame errors for our serial ports in emulation

                break :blk status;
            },
            else => return error.BusError,
        };
    }

    fn write16(busdev: *BusDevice, address: u24, value: u16) BusDevice.Error!void {
        const uart = @fieldParentPtr(Self, "bus_device", busdev);
        switch ((address & 0x7FF) >> 1) {
            0 => uart.output.writeItem(@truncate(u8, value)) catch return error.BusError, // TODO: write sent characters here
            else => return error.BusError,
        }
    }
};

const SDIO = struct {
    const Self = @This();

    bus_device: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = read16,
        .write16Fn = write16,
    },

    bus: *Bus,

    backing_file: ?std.fs.File = null,

    fn read16(busdev: *BusDevice, address: u24) !u16 {
        const sdio = @fieldParentPtr(Self, "bus_device", busdev);
        return switch ((address & 0x7FF) >> 1) {
            else => return error.BusError,
        };
    }

    fn write16(busdev: *BusDevice, address: u24, value: u16) !void {
        const sdio = @fieldParentPtr(Self, "bus_device", busdev);
        switch ((address & 0x7FF) >> 1) {
            else => return error.BusError,
        }
    }
};

comptime {
    std.debug.assert(@bitSizeOf(MMU.Register) == 16);
    std.debug.assert(@sizeOf(MMU.Register) == 2);
    std.debug.assert(@bitSizeOf(VGA.RGB) == 16);
    std.debug.assert(@sizeOf(VGA.RGB) == 2);
}

const hexfont_8x8 = [16][7]u8{
    [7]u8{
        0b11111,
        0b10001,
        0b10001,
        0b10001,
        0b10001,
        0b10001,
        0b11111,
    },
    [7]u8{
        0b00001,
        0b00001,
        0b00001,
        0b00001,
        0b00001,
        0b00001,
        0b00001,
    },
    [7]u8{
        0b11111,
        0b00001,
        0b00001,
        0b11111,
        0b10000,
        0b10000,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b00001,
        0b00001,
        0b11111,
        0b00001,
        0b00001,
        0b11111,
    },
    [7]u8{
        0b10001,
        0b10001,
        0b10001,
        0b11111,
        0b00001,
        0b00001,
        0b00001,
    },
    [7]u8{
        0b11111,
        0b10000,
        0b10000,
        0b11111,
        0b00001,
        0b00001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10000,
        0b10000,
        0b11111,
        0b10001,
        0b10001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b00001,
        0b00001,
        0b00111,
        0b00001,
        0b00001,
        0b00001,
    },
    [7]u8{
        0b11111,
        0b10001,
        0b10001,
        0b11111,
        0b10001,
        0b10001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10001,
        0b10001,
        0b11111,
        0b00001,
        0b00001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10001,
        0b10001,
        0b11111,
        0b10001,
        0b10001,
        0b10001,
    },
    [7]u8{
        0b10000,
        0b10000,
        0b10000,
        0b11111,
        0b10001,
        0b10001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10000,
        0b10000,
        0b10000,
        0b10000,
        0b10000,
        0b11111,
    },
    [7]u8{
        0b00001,
        0b00001,
        0b00001,
        0b11111,
        0b10001,
        0b10001,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10000,
        0b10000,
        0b11111,
        0b10000,
        0b10000,
        0b11111,
    },
    [7]u8{
        0b11111,
        0b10000,
        0b10000,
        0b11111,
        0b10000,
        0b10000,
        0b10000,
    },
};

fn isWordAlignedAddress(address: u24) bool {
    return (address & 1) == 0;
}

pub fn fileExtension(path: []const u8) ?[]const u8 {
    const filename = std.fs.path.basename(path);
    return if (std.mem.lastIndexOf(u8, filename, ".")) |index|
        if (index == 0 or index == filename.len - 1)
            null
        else
            filename[index + 1 ..]
    else
        null;
}
