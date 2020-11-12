const std = @import("std");

const sdl = @import("sdl2");

pub fn main() !void {
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

    main_loop: while (true) {
        while (sdl.pollEvent()) |event| {
            switch (event) {
                .quit => break :main_loop,
                else => {},
            }
        }

        var fb: [480][640]VGA.RGB = undefined;

        ashet.vga.render(&fb);

        try render_target.update(std.mem.sliceAsBytes(&fb), 640 * @sizeOf(VGA.RGB), null);

        try renderer.copy(render_target, null, null);

        renderer.present();
    }
}

const BusDevice = struct {
    const Self = @This();

    const UnmappedImpl = struct {
        fn read8(p: *Self, address: u24) u8 {
            return 0xFF;
        }
        fn read16(p: *Self, address: u24) u16 {
            return 0xFFFF;
        }

        fn write8(p: *Self, address: u24, value: u8) void {}
        fn write16(p: *Self, address: u24, value: u16) void {}
    };

    var unmapped_stor = Self{
        .read8Fn = UnmappedImpl.read8,
        .read16Fn = UnmappedImpl.read16,
        .write8Fn = UnmappedImpl.write8,
        .write16Fn = UnmappedImpl.write16,
    };
    pub const unmapped: *Self = &unmapped_stor;

    read8Fn: fn (*Self, u24) u8,
    read16Fn: fn (*Self, u24) u16,

    write8Fn: fn (*Self, u24, u8) void,
    write16Fn: fn (*Self, u24, u16) void,

    pub fn read8(self: *Self, address: u24) u8 {
        return self.read8Fn(self, address);
    }

    pub fn write8(self: *Self, address: u24, value: u8) void {
        return self.write8Fn(self, address, value);
    }

    pub fn read16(self: *Self, address: u24) u16 {
        return self.read16Fn(self, address);
    }

    pub fn write16(self: *Self, address: u24, value: u16) void {
        return self.write16Fn(self, address, value);
    }

    fn read16With8(self: *Self, address: u24) u16 {
        return (@as(u16, self.read8(address + 0)) << 0) |
            (@as(u16, self.read8(address + 1)) << 8);
    }

    fn write16With8(self: *Self, address: u24, value: u16) void {
        self.write16(address + 0, @truncate(u8, value >> 0));
        self.write16(address + 1, @truncate(u8, value >> 8));
    }

    fn read8With16(self: *Self, address: u24) u8 {
        const val = self.read16(address & 0xFFFE);
        return if ((address & 1) == 1)
            @truncate(u8, val >> 8)
        else
            @truncate(u8, val >> 0);
    }

    fn write8With16(self: *Self, address: u24, value: u8) void {
        const aligned_address = address & 0xFFFE;
        const current_val = self.read16(aligned_address);
        self.write16(aligned_address, if ((address & 1) == 1)
            (@as(u16, value) << 8) & (current_val & 0x00FF)
        else
            (@as(u16, value) << 0) & (current_val & 0xFF00));
    }
};

const Ashet = struct {
    const Self = @This();

    rom_buffer: [8388608]u8 = undefined, // 8 MB Flash
    ram_buffer: [524288]u8 = undefined, // 512 kB RAM

    // Memory interface
    bus: Bus,
    mmu: MMU,

    // Memory mapped parts
    ram: Memory,
    rom: Memory,
    vga: VGA,

    // After a call to init, `self` must not be moved anymore!
    pub fn init(self: *Self) void {
        self.* = Self{
            .bus = Bus{},
            .mmu = MMU{
                .bus = &self.bus,
            },

            .rom = Memory{ .data = &self.rom_buffer, .read_only = true },
            .ram = Memory{ .data = &self.rom_buffer, .read_only = false },
            .vga = VGA{
                .bus = &self.bus,
                .framebuffer_address = 0x000000,
            },
        };

        self.bus.mapRange(0x000000, 0x7FFFFF, &self.rom.bus_device);
        self.bus.mapRange(0x800000, 0xFFFFFF, &self.ram.bus_device);

        // - `0x7F0***`: (*Peripherial*) MMU Control/Status
        // - `0x7F1***`: (*Peripherial*) IRQ Controller
        // - `0x7F2***`: (*Peripherial*) UART'0
        // - `0x7F3***`: (*Peripherial*) UART'1
        // - `0x7F4***`: (*Peripherial*) PS/2'1 (Keyboar
        // - `0x7F5***`: (*Peripherial*) PS/2'2 (Mouse)
        // - `0x7F6***`: (*Peripherial*) SDIO'1
        // - `0x7F7***`: (*Peripherial*) SDIO'2
        // - `0x7F8***`: (*Peripherial*) Timer + RTC
        // - `0x7F9***`: (*Peripherial*) IrDA Interface
        // - `0x7FA***`: (*Peripherial*) Joystick Interf
        // - `0x7FB***`: (*Peripherial*) PCM Audio Contr
        // - `0x7FC***`: (*Peripherial*) DMA Control/Status
        self.bus.mapAddress(0x7FD000, &self.vga.bus_device_control);
        self.bus.mapAddress(0x7FE000, &self.vga.bus_device_palette);
        // - `0x7FF***`: (*Peripherial*) VGA Sprite Data
    }

    pub fn deinit(self: *Self) void {
        self.* = undefined;
    }
};

const Bus = struct {
    const Self = @This();

    devices: [4096]*BusDevice = [1]*BusDevice{&BusDevice.unmapped_stor} ** 4096,

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

    pub fn read8(self: *Self, address: u24) u8 {
        return self.deviceAt(address).read8(address);
    }

    pub fn write8(self: *Self, address: u24, value: u8) void {
        return self.deviceAt(address).write8(address, value);
    }

    pub fn read16(self: *Self, address: u24) u16 {
        return self.deviceAt(address).read16(address);
    }

    pub fn write16(self: *Self, address: u24, value: u16) void {
        return self.deviceAt(address).write16(address, value);
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

    fn read8(busdev: *BusDevice, address: u24) u8 {
        const mem = @fieldParentPtr(Self, "bus_device", busdev);
        const limit = std.math.ceilPowerOfTwo(usize, mem.data.len) catch unreachable;
        const offset = address & (limit - 1);

        return if (offset < mem.data.len)
            mem.data[offset]
        else
            0xFF;
    }

    fn write8(busdev: *BusDevice, address: u24, value: u8) void {
        const mem = @fieldParentPtr(Self, "bus_device", busdev);
        if (mem.read_only)
            return;

        const limit = std.math.ceilPowerOfTwo(usize, mem.data.len) catch unreachable;
        const offset = address & (limit - 1);

        if (offset < mem.data.len)
            mem.data[offset] = value;
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

    palette: [256]RGB = [_]RGB{
        RGB.init(0x00, 0x00, 0x00),
        RGB.init(0xFF, 0xFF, 0xFF),
    } ++ [_]RGB{RGB.init(0xFF, 0x00, 0x80)} ** 254,

    bus: *Bus,

    border_color: VGA.RGB = VGA.RGB.init(0x30, 0x34, 0x6d),
    framebuffer_address: u32 = 0x000000,

    pub fn render(self: Self, frame_buffer: *[480][640]VGA.RGB) void {
        for (frame_buffer) |*row, y| {
            for (row) |*pix, x| {
                pix.* = self.border_color;
            }
        }

        var offset = @truncate(u24, self.framebuffer_address & 0xFFFFFE);

        const dx = (640 - 256 * 2) / 2;
        const dy = (480 - 128 * 2) / 2;

        var y: usize = 0;
        while (y < 128) : (y += 1) {
            var x: usize = 0;
            while (x < 256) : (x += 2) {
                const pixels = self.bus.read16(offset);
                const low = self.palette[@truncate(u8, pixels >> 0)];
                const high = self.palette[@truncate(u8, pixels >> 8)];

                frame_buffer[dy + 2 * y + 0][dx + 2 * x + 0] = low;
                frame_buffer[dy + 2 * y + 1][dx + 2 * x + 0] = low;
                frame_buffer[dy + 2 * y + 0][dx + 2 * x + 1] = low;
                frame_buffer[dy + 2 * y + 1][dx + 2 * x + 1] = low;

                frame_buffer[dy + 2 * y + 0][dx + 2 * x + 2] = high;
                frame_buffer[dy + 2 * y + 1][dx + 2 * x + 2] = high;
                frame_buffer[dy + 2 * y + 0][dx + 2 * x + 3] = high;
                frame_buffer[dy + 2 * y + 1][dx + 2 * x + 3] = high;

                offset +%= 2; // might overflow
            }
        }
    }

    fn registerRead16(busdev: *BusDevice, address: u24) u16 {
        const vga = @fieldParentPtr(Self, "bus_device_control", busdev);
        return switch ((address & 0x7FF) >> 1) {
            else => 0xFFFF,
        };
    }

    fn registerWrite16(busdev: *BusDevice, address: u24, value: u16) void {
        const vga = @fieldParentPtr(Self, "bus_device_control", busdev);
        switch ((address & 0x7FF) >> 1) {
            else => {},
        }
    }

    fn paletteRead16(busdev: *BusDevice, address: u24) u16 {
        const vga = @fieldParentPtr(Self, "bus_device_palette", busdev);
        return @bitCast(u16, vga.palette[(address >> 1) & 0xFF]);
    }

    fn paletteWrite16(busdev: *BusDevice, address: u24, value: u16) void {
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

    bus_device: BusDevice = BusDevice{
        .read8Fn = BusDevice.read8With16,
        .write8Fn = BusDevice.write8With16,

        .read16Fn = registerRead16,
        .write16Fn = registerWrite16,
    },

    bus: *Bus,

    fn registerRead16(busdev: *BusDevice, address: u24) u16 {
        const mmu = @fieldParentPtr(Self, "bus_device", busdev);
        const register = (address & 0x7FF) >> 1;
        return switch (register) {
            0x000...0x00F => @bitCast(u16, mmu.page_config[register]),
            0x010 => mmu.page_fault_register,
            0x011 => mmu.write_fault_register,
            else => 0xFFFF,
        };
    }

    fn registerWrite16(busdev: *BusDevice, address: u24, value: u16) void {
        const mmu = @fieldParentPtr(Self, "bus_device", busdev);
        const register = (address & 0x7FF) >> 1;
        switch (register) {
            0x000...0x00F => mmu.page_config[register] = @bitCast(Register, value),
            0x010 => mmu.page_fault_register = value,
            0x011 => mmu.write_fault_register = value,
            else => {},
        }
    }
};

comptime {
    std.debug.assert(@bitSizeOf(MMU.Register) == 16);
    std.debug.assert(@sizeOf(MMU.Register) == 2);
    std.debug.assert(@bitSizeOf(VGA.RGB) == 16);
    std.debug.assert(@sizeOf(VGA.RGB) == 2);
}
