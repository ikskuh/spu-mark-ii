const std = @import("std");
const lpc1768 = @import("lpc1768");

const ISRHandler = fn () callconv(.Interrupt) void;

const start_of_ram = 0x10000000;
const stack_size = 0x2000;
const initial_sp = start_of_ram + stack_size;

var mutable_vector_table: @TypeOf(fixed_vector_table) = undefined;

extern var __bss__start: c_void;
extern var __bss__end: c_void;
extern var __text__end: c_void;
extern var __data__start: c_void;
extern var __data__end: c_void;

export fn _start() callconv(.Interrupt) noreturn {
    mutable_vector_table = fixed_vector_table;

    lpc1768.SCB.VTOR = @ptrToInt(&mutable_vector_table);
    lpc1768.SCB.SHP[7] = 1; // SVC has less priority than all fault handlers
    lpc1768.SCB.SHCSR = 0x00070000; // enable fault handler

    const bss = @ptrCast([*]u8, &__bss__start)[0 .. @ptrToInt(&__bss__end) - @ptrToInt(&__bss__end)];

    const ro_data = @ptrCast([*]const u8, &__text__end)[0 .. @ptrToInt(&__data__end) - @ptrToInt(&__data__start)];
    const rw_data = @ptrCast([*]u8, &__data__start)[0..ro_data.len];

    // BSS Segment löschen
    std.mem.set(u8, bss, 0);

    // Datasegment aus Flash in RAM kopieren
    std.mem.copy(u8, rw_data, ro_data);

    @import("root").main() catch |err| {
        @panic(@errorName(err));
    };
    while (true) {
        lpc1768.__disable_irq();
        lpc1768.__disable_fault_irq();
        lpc1768.__WFE();
    }
}

export fn _nmi() callconv(.Interrupt) void {
    @panic("nmi");
}

export fn _hardFault() callconv(.Interrupt) void {
    @panic("hard fault");
}

export fn _mpuFault() callconv(.Interrupt) void {
    @panic("mpu fault");
}

export fn _busFault() callconv(.Interrupt) void {
    @panic("bus fault");
}

export fn _usageFault() callconv(.Interrupt) void {
    @panic("usage fault");
}

export fn _unhandledInterrupt() callconv(.Interrupt) void {
    @panic("Unhandled interrupt!");
}

comptime {
    _ = fixed_vector_table;
}

const VectorTable = extern struct {
    initial_stack_pointer: u32 = initial_sp,

    reset: ISRHandler = _start,
    nmi: ISRHandler = _nmi,
    hard_fault: ISRHandler = _hardFault,
    mpu_fault: ISRHandler = _mpuFault,
    bus_fault: ISRHandler = _busFault,
    usage_fault: ISRHandler = _usageFault,

    checksum: u32 = undefined,

    reserved0: u32 = 0,
    reserved1: u32 = 0,
    reserved2: u32 = 0,

    svcall: ISRHandler = _unhandledInterrupt,
    debug_monitor: ISRHandler = _unhandledInterrupt,

    reserved3: u32 = 0,

    pendsv: ISRHandler = _unhandledInterrupt,
    systick: ISRHandler = _unhandledInterrupt,

    wdt: ISRHandler = _unhandledInterrupt,
    timer0: ISRHandler = _unhandledInterrupt,
    timer1: ISRHandler = _unhandledInterrupt,
    timer2: ISRHandler = _unhandledInterrupt,
    timer3: ISRHandler = _unhandledInterrupt,
    uart0: ISRHandler = _unhandledInterrupt,
    uart1: ISRHandler = _unhandledInterrupt,
    uart2: ISRHandler = _unhandledInterrupt,
    uart3: ISRHandler = _unhandledInterrupt,
    pwm1: ISRHandler = _unhandledInterrupt,
    i2c0: ISRHandler = _unhandledInterrupt,
    i2c1: ISRHandler = _unhandledInterrupt,
    i2c2: ISRHandler = _unhandledInterrupt,
    spi: ISRHandler = _unhandledInterrupt,
    ssp0: ISRHandler = _unhandledInterrupt,
    ssp1: ISRHandler = _unhandledInterrupt,
    pll0: ISRHandler = _unhandledInterrupt,
    rtc: ISRHandler = _unhandledInterrupt,
    eint0: ISRHandler = _unhandledInterrupt,
    eint1: ISRHandler = _unhandledInterrupt,
    eint2: ISRHandler = _unhandledInterrupt,
    eint3: ISRHandler = _unhandledInterrupt,
    adc: ISRHandler = _unhandledInterrupt,
    bod: ISRHandler = _unhandledInterrupt,
    usb: ISRHandler = _unhandledInterrupt,
    can: ISRHandler = _unhandledInterrupt,
    dma: ISRHandler = _unhandledInterrupt,
    i2s: ISRHandler = _unhandledInterrupt,
    enet: ISRHandler = _unhandledInterrupt,
    rit: ISRHandler = _unhandledInterrupt,
    mcpwm: ISRHandler = _unhandledInterrupt,
    qei: ISRHandler = _unhandledInterrupt,
    pll1: ISRHandler = _unhandledInterrupt,
};

export const fixed_vector_table: VectorTable linksection(".isr_vector") = VectorTable{};
