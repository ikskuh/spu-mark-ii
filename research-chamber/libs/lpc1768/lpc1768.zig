// Result from translate-c:

const std = @import("std");

test "" {
    std.meta.refAllDecls(@This());
}
pub inline fn __enable_irq() void {
    asm volatile ("cpsie i");
}
pub inline fn __disable_irq() void {
    asm volatile ("cpsid i");
}
pub inline fn __enable_fault_irq() void {
    asm volatile ("cpsie f");
}
pub inline fn __disable_fault_irq() void {
    asm volatile ("cpsid f");
}
pub inline fn __NOP() void {
    asm volatile ("nop");
}
pub inline fn __WFI() void {
    asm volatile ("wfi");
}
pub inline fn __WFE() void {
    asm volatile ("wfe");
}
pub inline fn __SEV() void {
    asm volatile ("sev");
}
pub inline fn __ISB() void {
    asm volatile ("isb");
}
pub inline fn __DSB() void {
    asm volatile ("dsb");
}
pub inline fn __DMB() void {
    asm volatile ("dmb");
}
pub inline fn __CLREX() void {
    asm volatile ("clrex");
}

pub const NonMaskableInt_IRQn = @enumToInt(IRQn.NonMaskableInt);
pub const MemoryManagement_IRQn = @enumToInt(IRQn.MemoryManagement);
pub const BusFault_IRQn = @enumToInt(IRQn.BusFault);
pub const UsageFault_IRQn = @enumToInt(IRQn.UsageFault);
pub const SVCall_IRQn = @enumToInt(IRQn.SVCall);
pub const DebugMonitor_IRQn = @enumToInt(IRQn.DebugMonitor);
pub const PendSV_IRQn = @enumToInt(IRQn.PendSV);
pub const SysTick_IRQn = @enumToInt(IRQn.SysTick);
pub const WDT_IRQn = @enumToInt(IRQn.WDT);
pub const TIMER0_IRQn = @enumToInt(IRQn.TIMER0);
pub const TIMER1_IRQn = @enumToInt(IRQn.TIMER1);
pub const TIMER2_IRQn = @enumToInt(IRQn.TIMER2);
pub const TIMER3_IRQn = @enumToInt(IRQn.TIMER3);
pub const UART0_IRQn = @enumToInt(IRQn.UART0);
pub const UART1_IRQn = @enumToInt(IRQn.UART1);
pub const UART2_IRQn = @enumToInt(IRQn.UART2);
pub const UART3_IRQn = @enumToInt(IRQn.UART3);
pub const PWM1_IRQn = @enumToInt(IRQn.PWM1);
pub const I2C0_IRQn = @enumToInt(IRQn.I2C0);
pub const I2C1_IRQn = @enumToInt(IRQn.I2C1);
pub const I2C2_IRQn = @enumToInt(IRQn.I2C2);
pub const SPI_IRQn = @enumToInt(IRQn.SPI);
pub const SSP0_IRQn = @enumToInt(IRQn.SSP0);
pub const SSP1_IRQn = @enumToInt(IRQn.SSP1);
pub const PLL0_IRQn = @enumToInt(IRQn.PLL0);
pub const RTC_IRQn = @enumToInt(IRQn.RTC);
pub const EINT0_IRQn = @enumToInt(IRQn.EINT0);
pub const EINT1_IRQn = @enumToInt(IRQn.EINT1);
pub const EINT2_IRQn = @enumToInt(IRQn.EINT2);
pub const EINT3_IRQn = @enumToInt(IRQn.EINT3);
pub const ADC_IRQn = @enumToInt(IRQn.ADC);
pub const BOD_IRQn = @enumToInt(IRQn.BOD);
pub const USB_IRQn = @enumToInt(IRQn.USB);
pub const CAN_IRQn = @enumToInt(IRQn.CAN);
pub const DMA_IRQn = @enumToInt(IRQn.DMA);
pub const I2S_IRQn = @enumToInt(IRQn.I2S);
pub const ENET_IRQn = @enumToInt(IRQn.ENET);
pub const RIT_IRQn = @enumToInt(IRQn.RIT);
pub const MCPWM_IRQn = @enumToInt(IRQn.MCPWM);
pub const QEI_IRQn = @enumToInt(IRQn.QEI);
pub const PLL1_IRQn = @enumToInt(IRQn.PLL1);

pub const IRQn = extern enum(isize) {
    NonMaskableInt = -14,
    MemoryManagement = -12,
    BusFault = -11,
    UsageFault = -10,
    SVCall = -5,
    DebugMonitor = -4,
    PendSV = -2,
    SysTick = -1,
    WDT = 0,
    TIMER0 = 1,
    TIMER1 = 2,
    TIMER2 = 3,
    TIMER3 = 4,
    UART0 = 5,
    UART1 = 6,
    UART2 = 7,
    UART3 = 8,
    PWM1 = 9,
    I2C0 = 10,
    I2C1 = 11,
    I2C2 = 12,
    SPI = 13,
    SSP0 = 14,
    SSP1 = 15,
    PLL0 = 16,
    RTC = 17,
    EINT0 = 18,
    EINT1 = 19,
    EINT2 = 20,
    EINT3 = 21,
    ADC = 22,
    BOD = 23,
    USB = 24,
    CAN = 25,
    DMA = 26,
    I2S = 27,
    ENET = 28,
    RIT = 29,
    MCPWM = 30,
    QEI = 31,
    PLL1 = 32,
    _,
};

pub const NVIC_Type = extern struct {
    ISER: [8]u32,
    RESERVED0: [24]u32,
    ICER: [8]u32,
    RSERVED1: [24]u32,
    ISPR: [8]u32,
    RESERVED2: [24]u32,
    ICPR: [8]u32,
    RESERVED3: [24]u32,
    IABR: [8]u32,
    RESERVED4: [56]u32,
    IP: [240]u8,
    RESERVED5: [644]u32,
    STIR: u32,
};

pub const SCB_Type = extern struct {
    CPUID: u32,
    ICSR: u32,
    VTOR: u32,
    AIRCR: u32,
    SCR: u32,
    CCR: u32,
    SHP: [12]u8,
    SHCSR: u32,
    CFSR: u32,
    HFSR: u32,
    DFSR: u32,
    MMFAR: u32,
    BFAR: u32,
    AFSR: u32,
    PFR: [2]u32,
    DFR: u32,
    ADR: u32,
    MMFR: [4]u32,
    ISAR: [5]u32,
};

pub const SysTick_Type = extern struct {
    CTRL: u32,
    LOAD: u32,
    VAL: u32,
    CALIB: u32,
};

const union_unnamed_5 = extern union {
    u8: u8,
    u16: u16,
    u32: u32,
};

pub const ITM_Type = extern struct {
    PORT: [32]union_unnamed_5,
    RESERVED0: [864]u32,
    TER: u32,
    RESERVED1: [15]u32,
    TPR: u32,
    RESERVED2: [15]u32,
    TCR: u32,
    RESERVED3: [29]u32,
    IWR: u32,
    IRR: u32,
    IMCR: u32,
    RESERVED4: [43]u32,
    LAR: u32,
    LSR: u32,
    RESERVED5: [6]u32,
    PID4: u32,
    PID5: u32,
    PID6: u32,
    PID7: u32,
    PID0: u32,
    PID1: u32,
    PID2: u32,
    PID3: u32,
    CID0: u32,
    CID1: u32,
    CID2: u32,
    CID3: u32,
};

pub const InterruptType_Type = extern struct {
    RESERVED0: u32,
    ICTR: u32,
    RESERVED1: u32,
};

pub const MPU_Type = extern struct {
    TYPE: u32,
    CTRL: u32,
    RNR: u32,
    RBAR: u32,
    RASR: u32,
    RBAR_A1: u32,
    RASR_A1: u32,
    RBAR_A2: u32,
    RASR_A2: u32,
    RBAR_A3: u32,
    RASR_A3: u32,
};

pub const CoreDebug_Type = extern struct {
    DHCSR: u32,
    DCRSR: u32,
    DCRDR: u32,
    DEMCR: u32,
};

pub extern fn __get_PSP() u32;
pub extern fn __set_PSP(topOfProcStack: u32) void;
pub extern fn __get_MSP() u32;
pub extern fn __set_MSP(topOfMainStack: u32) void;
pub extern fn __get_BASEPRI() u32;
pub extern fn __set_BASEPRI(basePri: u32) void;
pub extern fn __get_PRIMASK() u32;
pub extern fn __set_PRIMASK(priMask: u32) void;
pub extern fn __get_FAULTMASK() u32;
pub extern fn __set_FAULTMASK(faultMask: u32) void;
pub extern fn __get_CONTROL() u32;
pub extern fn __set_CONTROL(control: u32) void;
pub extern fn __REV(value: u32) u32;
pub extern fn __REV16(value: u16) u32;
pub extern fn __REVSH(value: i16) i32;
pub extern fn __RBIT(value: u32) u32;
pub extern fn __LDREXB(addr: [*c]u8) u8;
pub extern fn __LDREXH(addr: [*c]u16) u16;
pub extern fn __LDREXW(addr: [*c]u32) u32;
pub extern fn __STREXB(value: u8, addr: [*c]u8) u32;
pub extern fn __STREXH(value: u16, addr: [*c]u16) u32;
pub extern fn __STREXW(value: u32, addr: [*c]u32) u32;
pub inline fn NVIC_SetPriorityGrouping(PriorityGroup: u32) void {
    const PriorityGroupTmp = (PriorityGroup & 0x07); // only values 0..7 are used

    var reg_value = SCB.AIRCR; // read old register configuration
    reg_value &= ~((0xFFFF << 16) | (0x0F << 8)); // clear bits to change
    reg_value = ((reg_value | NVIC_AIRCR_VECTKEY | (PriorityGroupTmp << 8))); // Insert write key and priorty group
    SCB.AIRCR = reg_value;
}

// pub fn NVIC_GetPriorityGrouping() callconv(.C) u32 {
//     return (((@intToPtr([*c]SCB_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 3328))))).*.AIRCR >> @intCast(u5, 8)) & @bitCast(c_uint, @as(c_int, 7)));
// }

pub inline fn NVIC_SetHandler(irq: IRQn, handler: *allowzero const c_void) void {
    const base = @intToPtr([*]u32, SCB.VTOR);
    const offset = @intCast(usize, 16 + @enumToInt(irq));
    base[offset] = @bitCast(u32, @ptrToInt(handler));
}

// pub fn NVIC_EnableIRQ(arg_IRQn_1: IRQn) callconv(.C) void {
//     var IRQn_1 = arg_IRQn_1;
//     (@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.ISER[(@enumToInt((IRQn_1)) >> @intCast(u5, 5))] = @bitCast(u32, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))));
// }
// pub fn NVIC_DisableIRQ(arg_IRQn_1: IRQn) callconv(.C) void {
//     var IRQn_1 = arg_IRQn_1;
//     (@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.ICER[(@enumToInt((IRQn_1)) >> @intCast(u5, 5))] = @bitCast(u32, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))));
// }
// pub fn NVIC_GetPendingIRQ(arg_IRQn_1: IRQn) callconv(.C) u32 {
//     var IRQn_1 = arg_IRQn_1;
//     return (@bitCast(u32, (if (((@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.ISPR[@enumToInt((IRQn_1)) >> @intCast(u5, 5)] & @bitCast(c_uint, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))))) != 0) @as(c_int, 1) else @as(c_int, 0))));
// }
// pub fn NVIC_SetPendingIRQ(arg_IRQn_1: IRQn) callconv(.C) void {
//     var IRQn_1 = arg_IRQn_1;
//     (@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.ISPR[(@enumToInt((IRQn_1)) >> @intCast(u5, 5))] = @bitCast(u32, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))));
// }
// pub fn NVIC_ClearPendingIRQ(arg_IRQn_1: IRQn) callconv(.C) void {
//     var IRQn_1 = arg_IRQn_1;
//     (@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.ICPR[(@enumToInt((IRQn_1)) >> @intCast(u5, 5))] = @bitCast(u32, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))));
// }
// pub fn NVIC_GetActive(arg_IRQn_1: IRQn) callconv(.C) u32 {
//     var IRQn_1 = arg_IRQn_1;
//     return (@bitCast(u32, (if (((@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.IABR[@enumToInt((IRQn_1)) >> @intCast(u5, 5)] & @bitCast(c_uint, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 31))))))) != 0) @as(c_int, 1) else @as(c_int, 0))));
// }

const __MPU_PRESENT = 1;
const __NVIC_PRIO_BITS = 5;
const __Vendor_SysTickConfig = 0;
pub inline fn NVIC_SetPriority(irq: IRQn, priority: u32) void {
    const irq_number = @enumToInt(irq);
    if (irq_number < 0) {
        // set Priority for Cortex-M3 System Interrupts
        SCB.SHP[@intCast(u32, irq_number & 0xF) - 4] = @truncate(u8, priority << (8 - __NVIC_PRIO_BITS));
    } else { // set Priority for device specific Interrupts
        NVIC.IP[@intCast(u32, irq_number)] = @truncate(u8, priority << (8 - __NVIC_PRIO_BITS));
    }
}

// pub fn NVIC_GetPriority(arg_IRQn_1: IRQn) callconv(.C) u32 {
//     var IRQn_1 = arg_IRQn_1;
//     if (@enumToInt(IRQn_1) < @as(c_int, 0)) {
//         return (@bitCast(u32, (@bitCast(c_int, @as(c_uint, (@intToPtr([*c]SCB_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 3328))))).*.SHP[((@enumToInt((IRQn_1)) & @bitCast(c_uint, @as(c_int, 15))) -% @bitCast(c_uint, @as(c_int, 4)))])) >> @intCast(std.math.Log2Int(c_int), (@as(c_int, 8) - @as(c_int, 5))))));
//     } else {
//         return (@bitCast(u32, (@bitCast(c_int, @as(c_uint, (@intToPtr([*c]NVIC_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 256))))).*.IP[@enumToInt((IRQn_1))])) >> @intCast(std.math.Log2Int(c_int), (@as(c_int, 8) - @as(c_int, 5))))));
//     }
//     return 0;
// }
// pub fn NVIC_EncodePriority(arg_PriorityGroup: u32, arg_PreemptPriority: u32, arg_SubPriority: u32) callconv(.C) u32 {
//     var PriorityGroup = arg_PriorityGroup;
//     var PreemptPriority = arg_PreemptPriority;
//     var SubPriority = arg_SubPriority;
//     var PriorityGroupTmp: u32 = (PriorityGroup & @bitCast(c_uint, @as(c_int, 7)));
//     var PreemptPriorityBits: u32 = undefined;
//     var SubPriorityBits: u32 = undefined;
//     PreemptPriorityBits = if ((@bitCast(c_uint, @as(c_int, 7)) -% PriorityGroupTmp) > @bitCast(c_uint, @as(c_int, 5))) @bitCast(c_uint, @as(c_int, 5)) else (@bitCast(c_uint, @as(c_int, 7)) -% PriorityGroupTmp);
//     SubPriorityBits = if ((PriorityGroupTmp +% @bitCast(c_uint, @as(c_int, 5))) < @bitCast(c_uint, @as(c_int, 7))) @bitCast(c_uint, @as(c_int, 0)) else ((PriorityGroupTmp -% @bitCast(c_uint, @as(c_int, 7))) +% @bitCast(c_uint, @as(c_int, 5)));
//     return (((PreemptPriority & @bitCast(c_uint, ((@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (PreemptPriorityBits))) - @as(c_int, 1)))) << @intCast(std.math.Log2Int(c_uint), SubPriorityBits)) | (SubPriority & @bitCast(c_uint, ((@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (SubPriorityBits))) - @as(c_int, 1)))));
// }
// pub fn NVIC_DecodePriority(arg_Priority: u32, arg_PriorityGroup: u32, arg_pPreemptPriority: [*c]u32, arg_pSubPriority: [*c]u32) callconv(.C) void {
//     var Priority = arg_Priority;
//     var PriorityGroup = arg_PriorityGroup;
//     var pPreemptPriority = arg_pPreemptPriority;
//     var pSubPriority = arg_pSubPriority;
//     var PriorityGroupTmp: u32 = (PriorityGroup & @bitCast(c_uint, @as(c_int, 7)));
//     var PreemptPriorityBits: u32 = undefined;
//     var SubPriorityBits: u32 = undefined;
//     PreemptPriorityBits = if ((@bitCast(c_uint, @as(c_int, 7)) -% PriorityGroupTmp) > @bitCast(c_uint, @as(c_int, 5))) @bitCast(c_uint, @as(c_int, 5)) else (@bitCast(c_uint, @as(c_int, 7)) -% PriorityGroupTmp);
//     SubPriorityBits = if ((PriorityGroupTmp +% @bitCast(c_uint, @as(c_int, 5))) < @bitCast(c_uint, @as(c_int, 7))) @bitCast(c_uint, @as(c_int, 0)) else ((PriorityGroupTmp -% @bitCast(c_uint, @as(c_int, 7))) +% @bitCast(c_uint, @as(c_int, 5)));
//     pPreemptPriority.?.* = ((Priority >> @intCast(u5, SubPriorityBits)) & @bitCast(c_uint, ((@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (PreemptPriorityBits))) - @as(c_int, 1))));
//     pSubPriority.?.* = ((Priority) & @bitCast(c_uint, ((@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), (SubPriorityBits))) - @as(c_int, 1))));
// }

pub inline fn SysTick_Config(ticks: u24) !void {
    if (ticks > SYSTICK_MAXCOUNT) // Reload value impossible
        return error.OutOfRange;

    SysTick.LOAD = (ticks & SYSTICK_MAXCOUNT) - 1; // set reload register
    NVIC_SetPriority(.SysTick, (1 << __NVIC_PRIO_BITS) - 1); // set Priority for Cortex-M0 System Interrupts
    SysTick.VAL = 0x00; // Load the SysTick Counter Value
    SysTick.CTRL = (1 << SYSTICK_CLKSOURCE) | (1 << SYSTICK_ENABLE) | (1 << SYSTICK_TICKINT); // Enable SysTick IRQ and SysTick Timer
}

// pub fn NVIC_SystemReset() callconv(.C) void {
//     (@intToPtr([*c]SCB_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 3328))))).*.AIRCR = ((@bitCast(c_uint, (@as(c_int, 1530) << @intCast(std.math.Log2Int(c_int), 16))) | ((@intToPtr([*c]SCB_Type, ((@as(c_uint, 3758153728)) +% @bitCast(c_uint, @as(c_int, 3328))))).*.AIRCR & @bitCast(c_uint, (@as(c_int, 1792))))) | @bitCast(c_uint, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), 2))));
//     __DSB();
//     while (true) {}
// }
// pub fn ITM_SendChar(arg_ch: u32) callconv(.C) u32 {
//     var ch = arg_ch;
//     if (ch == @bitCast(c_uint, @as(c_int, '\n'))) _ = ITM_SendChar(@bitCast(u32, @as(c_int, '\r')));
//     if (((((@intToPtr([*c]CoreDebug_Type, (@as(c_uint, 3758157296)))).*.DEMCR & @bitCast(c_uint, (@as(c_int, 1) << @intCast(std.math.Log2Int(c_int), 24)))) != 0) and (((@intToPtr([*c]ITM_Type, (@as(c_uint, 3758096384)))).*.TCR & @bitCast(c_uint, @as(c_int, 1))) != 0)) and ((@bitCast(c_ulong, @as(c_ulong, (@intToPtr([*c]ITM_Type, (@as(c_uint, 3758096384)))).*.TER)) & (@as(c_ulong, 1) << @intCast(std.math.Log2Int(c_ulong), 0))) != 0)) {
//         while ((@intToPtr([*c]ITM_Type, (@as(c_uint, 3758096384)))).*.PORT[@intCast(c_uint, @as(c_int, 0))].u32 == @bitCast(c_uint, @as(c_int, 0))) {}
//         (@intToPtr([*c]ITM_Type, (@as(c_uint, 3758096384)))).*.PORT[@intCast(c_uint, @as(c_int, 0))].u8 = @bitCast(u8, @truncate(u8, ch));
//     }
//     return (ch);
// }

pub const LPC_SC_TypeDef = extern struct {
    const Self = @This();

    pub const Peripherial = enum(u5) {
        tim0 = 1,
        tim1 = 2,
        uart0 = 3,
        uart1 = 4,
        pwm1 = 6,
        i2c0 = 7,
        spi = 8,
        rtc = 9,
        ssp1 = 10,
        adc = 12,
        can1 = 13,
        can2 = 14,
        gpio = 15,
        rit = 16,
        mcpwm = 17,
        qei = 18,
        i2c1 = 19,
        ssp0 = 21,
        tim2 = 22,
        tim3 = 23,
        uart2 = 24,
        uart3 = 25,
        i2c2 = 26,
        i2s = 27,
        gpdma = 29,
        enet = 30,
        usb = 31,
    };

    pub const Power = packed enum(u1) { off = 0, on = 1 };

    pub fn setPeripherialPower(self: *volatile Self, peripherial: Peripherial, power: Power) void {
        switch (power) {
            .on => self.PCONP |= (@as(u32, 1) << @enumToInt(peripherial)),
            .off => self.PCONP &= ~(@as(u32, 1) << @enumToInt(peripherial)),
        }
    }

    FLASHCFG: u32,
    RESERVED0: [31]u32,
    PLL0CON: u32,
    PLL0CFG: u32,
    PLL0STAT: u32,
    PLL0FEED: u32,
    RESERVED1: [4]u32,
    PLL1CON: u32,
    PLL1CFG: u32,
    PLL1STAT: u32,
    PLL1FEED: u32,
    RESERVED2: [4]u32,
    PCON: u32,
    PCONP: u32,
    RESERVED3: [15]u32,
    CCLKCFG: u32,
    USBCLKCFG: u32,
    CLKSRCSEL: u32,
    RESERVED4: [12]u32,
    EXTINT: u32,
    RESERVED5: u32,
    EXTMODE: u32,
    EXTPOLAR: u32,
    RESERVED6: [12]u32,
    RSID: u32,
    RESERVED7: [7]u32,
    SCS: u32,
    IRCTRIM: u32,
    PCLKSEL0: u32,
    PCLKSEL1: u32,
    RESERVED8: [4]u32,
    USBIntSt: u32,
    RESERVED9: u32,
    CLKOUTCFG: u32,
};

pub const LPC_PINCON_TypeDef = extern struct {
    PINSEL: [10]u32,
    RESERVED0: [5]u32,
    PINMODE: [10]u32,
    PINMODE_OD: [5]u32,
    I2CPADCFG: u32,
};

pub const LPC_GPIO_TypeDef = extern struct {
    FIODIR: u32,
    RESERVED0: [3]u32,
    FIOMASK: u32,
    FIOPIN: u32,
    FIOSET: u32,
    FIOCLR: u32,
};

pub const LPC_GPIOINT_TypeDef = extern struct {
    IntStatus: u32,
    IO0IntStatR: u32,
    IO0IntStatF: u32,
    IO0IntClr: u32,
    IO0IntEnR: u32,
    IO0IntEnF: u32,
    RESERVED0: [3]u32,
    IO2IntStatR: u32,
    IO2IntStatF: u32,
    IO2IntClr: u32,
    IO2IntEnR: u32,
    IO2IntEnF: u32,
};

pub const LPC_TIM_TypeDef = extern struct {
    IR: u32,
    TCR: u32,
    TC: u32,
    PR: u32,
    PC: u32,
    MCR: u32,
    MR0: u32,
    MR1: u32,
    MR2: u32,
    MR3: u32,
    CCR: u32,
    CR0: u32,
    CR1: u32,
    RESERVED0: [2]u32,
    EMR: u32,
    RESERVED1: [12]u32,
    CTCR: u32,
};

pub const LPC_PWM_TypeDef = extern struct {
    IR: u32,
    TCR: u32,
    TC: u32,
    PR: u32,
    PC: u32,
    MCR: u32,
    MR0: u32,
    MR1: u32,
    MR2: u32,
    MR3: u32,
    CCR: u32,
    CR0: u32,
    CR1: u32,
    CR2: u32,
    CR3: u32,
    RESERVED0: u32,
    MR4: u32,
    MR5: u32,
    MR6: u32,
    PCR: u32,
    LER: u32,
    RESERVED1: [7]u32,
    CTCR: u32,
};

pub const LPC_UART_TypeDef = extern struct {
    unnamed_0: extern union {
        RBR: u8,
        THR: u8,
        DLL: u8,
        RESERVED0: u32,
    },
    unnamed_1: extern union {
        DLM: u8,
        IER: u32,
    },
    unnamed_2: extern union {
        IIR: u32,
        FCR: u8,
    },
    LCR: u8,
    RESERVED1: [7]u8,
    LSR: u8,
    RESERVED2: [7]u8,
    SCR: u8,
    RESERVED3: [3]u8,
    ACR: u32,
    ICR: u8,
    RESERVED4: [3]u8,
    FDR: u8,
    RESERVED5: [7]u8,
    TER: u8,
    RESERVED6: [39]u8,
    FIFOLVL: u8,
};

pub const LPC_UART0_TypeDef = extern struct {
    uart: LPC_UART_TypeDef,
    RESERVED7: [363]u8,
    DMAREQSEL: u32,
};

pub const LPC_UART1_TypeDef = extern struct {
    unnamed_0: extern union {
        RBR: u8,
        THR: u8,
        DLL: u8,
        RESERVED0: u32,
    },
    unnamed_1: extern union {
        DLM: u8,
        IER: u32,
    },
    unnamed_2: extern union {
        IIR: u32,
        FCR: u8,
    },
    LCR: u8,
    RESERVED1: [3]u8,
    MCR: u8,
    RESERVED2: [3]u8,
    LSR: u8,
    RESERVED3: [3]u8,
    MSR: u8,
    RESERVED4: [3]u8,
    SCR: u8,
    RESERVED5: [3]u8,
    ACR: u32,
    RESERVED6: u32,
    FDR: u32,
    RESERVED7: u32,
    TER: u8,
    RESERVED8: [27]u8,
    RS485CTRL: u8,
    RESERVED9: [3]u8,
    ADRMATCH: u8,
    RESERVED10: [3]u8,
    RS485DLY: u8,
    RESERVED11: [3]u8,
    FIFOLVL: u8,
};

pub const LPC_SPI_TypeDef = extern struct {
    SPCR: u32,
    SPSR: u32,
    SPDR: u32,
    SPCCR: u32,
    RESERVED0: [3]u32,
    SPINT: u32,
};

pub const LPC_SSP_TypeDef = extern struct {
    CR0: u32,
    CR1: u32,
    DR: u32,
    SR: u32,
    CPSR: u32,
    IMSC: u32,
    RIS: u32,
    MIS: u32,
    ICR: u32,
    DMACR: u32,
};

pub const LPC_I2C_TypeDef = extern struct {
    I2CONSET: u32,
    I2STAT: u32,
    I2DAT: u32,
    I2ADR0: u32,
    I2SCLH: u32,
    I2SCLL: u32,
    I2CONCLR: u32,
    MMCTRL: u32,
    I2ADR1: u32,
    I2ADR2: u32,
    I2ADR3: u32,
    I2DATA_BUFFER: u32,
    I2MASK0: u32,
    I2MASK1: u32,
    I2MASK2: u32,
    I2MASK3: u32,
};

pub const LPC_I2S_TypeDef = extern struct {
    I2SDAO: u32,
    I2SDAI: u32,
    I2STXFIFO: u32,
    I2SRXFIFO: u32,
    I2SSTATE: u32,
    I2SDMA1: u32,
    I2SDMA2: u32,
    I2SIRQ: u32,
    I2STXRATE: u32,
    I2SRXRATE: u32,
    I2STXBITRATE: u32,
    I2SRXBITRATE: u32,
    I2STXMODE: u32,
    I2SRXMODE: u32,
};

pub const LPC_RIT_TypeDef = extern struct {
    RICOMPVAL: u32,
    RIMASK: u32,
    RICTRL: u8,
    RESERVED0: [3]u8,
    RICOUNTER: u32,
};

pub const LPC_RTC_TypeDef = extern struct {
    ILR: u8,
    RESERVED0: [7]u8,
    CCR: u8,
    RESERVED1: [3]u8,
    CIIR: u8,
    RESERVED2: [3]u8,
    AMR: u8,
    RESERVED3: [3]u8,
    CTIME0: u32,
    CTIME1: u32,
    CTIME2: u32,
    SEC: u8,
    RESERVED4: [3]u8,
    MIN: u8,
    RESERVED5: [3]u8,
    HOUR: u8,
    RESERVED6: [3]u8,
    DOM: u8,
    RESERVED7: [3]u8,
    DOW: u8,
    RESERVED8: [3]u8,
    DOY: u16,
    RESERVED9: u16,
    MONTH: u8,
    RESERVED10: [3]u8,
    YEAR: u16,
    RESERVED11: u16,
    CALIBRATION: u32,
    GPREG0: u32,
    GPREG1: u32,
    GPREG2: u32,
    GPREG3: u32,
    GPREG4: u32,
    RTC_AUXEN: u8,
    RESERVED12: [3]u8,
    RTC_AUX: u8,
    RESERVED13: [3]u8,
    ALSEC: u8,
    RESERVED14: [3]u8,
    ALMIN: u8,
    RESERVED15: [3]u8,
    ALHOUR: u8,
    RESERVED16: [3]u8,
    ALDOM: u8,
    RESERVED17: [3]u8,
    ALDOW: u8,
    RESERVED18: [3]u8,
    ALDOY: u16,
    RESERVED19: u16,
    ALMON: u8,
    RESERVED20: [3]u8,
    ALYEAR: u16,
    RESERVED21: u16,
};

pub const LPC_WDT_TypeDef = extern struct {
    WDMOD: u8,
    RESERVED0: [3]u8,
    WDTC: u32,
    WDFEED: u8,
    RESERVED1: [3]u8,
    WDTV: u32,
    WDCLKSEL: u32,
};

pub const LPC_ADC_TypeDef = extern struct {
    ADCR: u32,
    ADGDR: u32,
    RESERVED0: u32,
    ADINTEN: u32,
    ADDR0: u32,
    ADDR1: u32,
    ADDR2: u32,
    ADDR3: u32,
    ADDR4: u32,
    ADDR5: u32,
    ADDR6: u32,
    ADDR7: u32,
    ADSTAT: u32,
    ADTRM: u32,
};

pub const LPC_DAC_TypeDef = extern struct {
    DACR: u32,
    DACCTRL: u32,
    DACCNTVAL: u16,
};

pub const LPC_MCPWM_TypeDef = extern struct {
    MCCON: u32,
    MCCON_SET: u32,
    MCCON_CLR: u32,
    MCCAPCON: u32,
    MCCAPCON_SET: u32,
    MCCAPCON_CLR: u32,
    MCTIM0: u32,
    MCTIM1: u32,
    MCTIM2: u32,
    MCPER0: u32,
    MCPER1: u32,
    MCPER2: u32,
    MCPW0: u32,
    MCPW1: u32,
    MCPW2: u32,
    MCDEADTIME: u32,
    MCCCP: u32,
    MCCR0: u32,
    MCCR1: u32,
    MCCR2: u32,
    MCINTEN: u32,
    MCINTEN_SET: u32,
    MCINTEN_CLR: u32,
    MCCNTCON: u32,
    MCCNTCON_SET: u32,
    MCCNTCON_CLR: u32,
    MCINTFLAG: u32,
    MCINTFLAG_SET: u32,
    MCINTFLAG_CLR: u32,
    MCCAP_CLR: u32,
};

pub const LPC_QEI_TypeDef = extern struct {
    QEICON: u32,
    QEISTAT: u32,
    QEICONF: u32,
    QEIPOS: u32,
    QEIMAXPOS: u32,
    CMPOS0: u32,
    CMPOS1: u32,
    CMPOS2: u32,
    INXCNT: u32,
    INXCMP: u32,
    QEILOAD: u32,
    QEITIME: u32,
    QEIVEL: u32,
    QEICAP: u32,
    VELCOMP: u32,
    FILTER: u32,
    RESERVED0: [998]u32,
    QEIIEC: u32,
    QEIIES: u32,
    QEIINTSTAT: u32,
    QEIIE: u32,
    QEICLR: u32,
    QEISET: u32,
};

pub const LPC_CANAF_RAM_TypeDef = extern struct {
    mask: [512]u32,
};

pub const LPC_CANAF_TypeDef = extern struct {
    AFMR: u32,
    SFF_sa: u32,
    SFF_GRP_sa: u32,
    EFF_sa: u32,
    EFF_GRP_sa: u32,
    ENDofTable: u32,
    LUTerrAd: u32,
    LUTerr: u32,
    FCANIE: u32,
    FCANIC0: u32,
    FCANIC1: u32,
};

pub const LPC_CANCR_TypeDef = extern struct {
    CANTxSR: u32,
    CANRxSR: u32,
    CANMSR: u32,
};

pub const LPC_CAN_TypeDef = extern struct {
    MOD: u32,
    CMR: u32,
    GSR: u32,
    ICR: u32,
    IER: u32,
    BTR: u32,
    EWL: u32,
    SR: u32,
    RFS: u32,
    RID: u32,
    RDA: u32,
    RDB: u32,
    TFI1: u32,
    TID1: u32,
    TDA1: u32,
    TDB1: u32,
    TFI2: u32,
    TID2: u32,
    TDA2: u32,
    TDB2: u32,
    TFI3: u32,
    TID3: u32,
    TDA3: u32,
    TDB3: u32,
};

pub const LPC_GPDMA_TypeDef = extern struct {
    DMACIntStat: u32,
    DMACIntTCStat: u32,
    DMACIntTCClear: u32,
    DMACIntErrStat: u32,
    DMACIntErrClr: u32,
    DMACRawIntTCStat: u32,
    DMACRawIntErrStat: u32,
    DMACEnbldChns: u32,
    DMACSoftBReq: u32,
    DMACSoftSReq: u32,
    DMACSoftLBReq: u32,
    DMACSoftLSReq: u32,
    DMACConfig: u32,
    DMACSync: u32,
};

pub const LPC_GPDMACH_TypeDef = extern struct {
    DMACCSrcAddr: u32,
    DMACCDestAddr: u32,
    DMACCLLI: u32,
    DMACCControl: u32,
    DMACCConfig: u32,
};

const union_unnamed_45 = extern union {
    USBClkCtrl: u32,
    OTGClkCtrl: u32,
};
const union_unnamed_46 = extern union {
    USBClkSt: u32,
    OTGClkSt: u32,
};

pub const LPC_USB_TypeDef = extern struct {
    HcRevision: u32,
    HcControl: u32,
    HcCommandStatus: u32,
    HcInterruptStatus: u32,
    HcInterruptEnable: u32,
    HcInterruptDisable: u32,
    HcHCCA: u32,
    HcPeriodCurrentED: u32,
    HcControlHeadED: u32,
    HcControlCurrentED: u32,
    HcBulkHeadED: u32,
    HcBulkCurrentED: u32,
    HcDoneHead: u32,
    HcFmInterval: u32,
    HcFmRemaining: u32,
    HcFmNumber: u32,
    HcPeriodicStart: u32,
    HcLSTreshold: u32,
    HcRhDescriptorA: u32,
    HcRhDescriptorB: u32,
    HcRhStatus: u32,
    HcRhPortStatus1: u32,
    HcRhPortStatus2: u32,
    RESERVED0: [40]u32,
    Module_ID: u32,
    OTGIntSt: u32,
    OTGIntEn: u32,
    OTGIntSet: u32,
    OTGIntClr: u32,
    OTGStCtrl: u32,
    OTGTmr: u32,
    RESERVED1: [58]u32,
    USBDevIntSt: u32,
    USBDevIntEn: u32,
    USBDevIntClr: u32,
    USBDevIntSet: u32,
    USBCmdCode: u32,
    USBCmdData: u32,
    USBRxData: u32,
    USBTxData: u32,
    USBRxPLen: u32,
    USBTxPLen: u32,
    USBCtrl: u32,
    USBDevIntPri: u32,
    USBEpIntSt: u32,
    USBEpIntEn: u32,
    USBEpIntClr: u32,
    USBEpIntSet: u32,
    USBEpIntPri: u32,
    USBReEp: u32,
    USBEpInd: u32,
    USBMaxPSize: u32,
    USBDMARSt: u32,
    USBDMARClr: u32,
    USBDMARSet: u32,
    RESERVED2: [9]u32,
    USBUDCAH: u32,
    USBEpDMASt: u32,
    USBEpDMAEn: u32,
    USBEpDMADis: u32,
    USBDMAIntSt: u32,
    USBDMAIntEn: u32,
    RESERVED3: [2]u32,
    USBEoTIntSt: u32,
    USBEoTIntClr: u32,
    USBEoTIntSet: u32,
    USBNDDRIntSt: u32,
    USBNDDRIntClr: u32,
    USBNDDRIntSet: u32,
    USBSysErrIntSt: u32,
    USBSysErrIntClr: u32,
    USBSysErrIntSet: u32,
    RESERVED4: [15]u32,
    I2C_RX: u32,
    I2C_WO: u32,
    I2C_STS: u32,
    I2C_CTL: u32,
    I2C_CLKHI: u32,
    I2C_CLKLO: u32,
    RESERVED5: [823]u32,
    unnamed_0: union_unnamed_45,
    unnamed_1: union_unnamed_46,
};

pub const LPC_EMAC_TypeDef = extern struct {
    MAC1: u32,
    MAC2: u32,
    IPGT: u32,
    IPGR: u32,
    CLRT: u32,
    MAXF: u32,
    SUPP: u32,
    TEST: u32,
    MCFG: u32,
    MCMD: u32,
    MADR: u32,
    MWTD: u32,
    MRDD: u32,
    MIND: u32,
    RESERVED0: [2]u32,
    SA0: u32,
    SA1: u32,
    SA2: u32,
    RESERVED1: [45]u32,
    Command: u32,
    Status: u32,
    RxDescriptor: u32,
    RxStatus: u32,
    RxDescriptorNumber: u32,
    RxProduceIndex: u32,
    RxConsumeIndex: u32,
    TxDescriptor: u32,
    TxStatus: u32,
    TxDescriptorNumber: u32,
    TxProduceIndex: u32,
    TxConsumeIndex: u32,
    RESERVED2: [10]u32,
    TSV0: u32,
    TSV1: u32,
    RSV: u32,
    RESERVED3: [3]u32,
    FlowControlCounter: u32,
    FlowControlStatus: u32,
    RESERVED4: [34]u32,
    RxFilterCtrl: u32,
    RxFilterWoLStatus: u32,
    RxFilterWoLClear: u32,
    RESERVED5: u32,
    HashFilterL: u32,
    HashFilterH: u32,
    RESERVED6: [882]u32,
    IntStatus: u32,
    IntEnable: u32,
    IntClear: u32,
    IntSet: u32,
    RESERVED7: u32,
    PowerDown: u32,
    RESERVED8: u32,
    Module_ID: u32,
};

pub const NVIC_VECTRESET = 0;
pub const NVIC_SYSRESETREQ = 2;
pub const NVIC_AIRCR_VECTKEY = 0x5FA << 16;
pub const NVIC_AIRCR_ENDIANESS = 15;
pub const CoreDebug_DEMCR_TRCENA = 1 << 24;
pub const ITM_TCR_ITMENA = 1;
pub const SCS_BASE = 0xE000E000;
pub const ITM_BASE = 0xE0000000;
pub const CoreDebug_BASE = 0xE000EDF0;
pub const SysTick_BASE = SCS_BASE + 0x0010;
pub const NVIC_BASE = SCS_BASE + 0x0100;
pub const SCB_BASE = SCS_BASE + 0x0D00;
pub const InterruptType = @intToPtr(*volatile InterruptType_Type, SCS_BASE);
pub const SCB = @intToPtr(*volatile SCB_Type, SCB_BASE);
pub const SysTick = @intToPtr(*volatile SysTick_Type, SysTick_BASE);
pub const NVIC = @intToPtr(*volatile NVIC_Type, NVIC_BASE);
pub const ITM = @intToPtr(*volatile ITM_Type, ITM_BASE);
pub const CoreDebug = @intToPtr(*volatile CoreDebug_Type, CoreDebug_BASE);
pub const MPU_BASE = SCS_BASE + 0x0D90;
pub const MPU = @intToPtr(*volatile MPU_Type, MPU_BASE);
pub const SYSTICK_ENABLE = 0;
pub const SYSTICK_TICKINT = 1;
pub const SYSTICK_CLKSOURCE = 2;
pub const SYSTICK_MAXCOUNT = (1 << 24) - 1;
pub const FLASH_BASE = 0x00000000;
pub const RAM_BASE = 0x10000000;
pub const GPIO_BASE = 0x2009C000;
pub const APB0_BASE = 0x40000000;
pub const APB1_BASE = 0x40080000;
pub const AHB_BASE = 0x50000000;
pub const CM3_BASE = 0xE0000000;
pub const WDT_BASE = APB0_BASE + 0x00000;
pub const TIM0_BASE = APB0_BASE + 0x04000;
pub const TIM1_BASE = APB0_BASE + 0x08000;
pub const UART0_BASE = APB0_BASE + 0x0C000;
pub const UART1_BASE = APB0_BASE + 0x10000;
pub const PWM1_BASE = APB0_BASE + 0x18000;
pub const I2C0_BASE = APB0_BASE + 0x1C000;
pub const SPI_BASE = APB0_BASE + 0x20000;
pub const RTC_BASE = APB0_BASE + 0x24000;
pub const GPIOINT_BASE = APB0_BASE + 0x28080;
pub const PINCON_BASE = APB0_BASE + 0x2C000;
pub const SSP1_BASE = APB0_BASE + 0x30000;
pub const ADC_BASE = APB0_BASE + 0x34000;
pub const CANAF_RAM_BASE = APB0_BASE + 0x38000;
pub const CANAF_BASE = APB0_BASE + 0x3C000;
pub const CANCR_BASE = APB0_BASE + 0x40000;
pub const CAN1_BASE = APB0_BASE + 0x44000;
pub const CAN2_BASE = APB0_BASE + 0x48000;
pub const I2C1_BASE = APB0_BASE + 0x5C000;
pub const SSP0_BASE = APB1_BASE + 0x08000;
pub const DAC_BASE = APB1_BASE + 0x0C000;
pub const TIM2_BASE = APB1_BASE + 0x10000;
pub const TIM3_BASE = APB1_BASE + 0x14000;
pub const UART2_BASE = APB1_BASE + 0x18000;
pub const UART3_BASE = APB1_BASE + 0x1C000;
pub const I2C2_BASE = APB1_BASE + 0x20000;
pub const I2S_BASE = APB1_BASE + 0x28000;
pub const RIT_BASE = APB1_BASE + 0x30000;
pub const MCPWM_BASE = PB1_BASE + 0x38000;
pub const QEI_BASE = APB1_BASE + 0x3C000;
pub const SC_BASE = APB1_BASE + 0x7C000;
pub const EMAC_BASE = AHB_BASE + 0x00000;
pub const GPDMA_BASE = AHB_BASE + 0x04000;
pub const GPDMACH0_BASE = AHB_BASE + 0x04100;
pub const GPDMACH1_BASE = AHB_BASE + 0x04120;
pub const GPDMACH2_BASE = AHB_BASE + 0x04140;
pub const GPDMACH3_BASE = AHB_BASE + 0x04160;
pub const GPDMACH4_BASE = AHB_BASE + 0x04180;
pub const GPDMACH5_BASE = AHB_BASE + 0x041A0;
pub const GPDMACH6_BASE = AHB_BASE + 0x041C0;
pub const GPDMACH7_BASE = AHB_BASE + 0x041E0;
pub const USB_BASE = AHB_BASE + 0x0C000;
pub const GPIO0_BASE = GPIO_BASE + 0x00000;
pub const GPIO1_BASE = GPIO_BASE + 0x00020;
pub const GPIO2_BASE = GPIO_BASE + 0x00040;
pub const GPIO3_BASE = GPIO_BASE + 0x00060;
pub const GPIO4_BASE = GPIO_BASE + 0x00080;
pub inline fn __LPC_MODULE(comptime _Type: type, comptime _Base: u32) *volatile _Type {
    return @intToPtr(*volatile _Type, _Base);
}

pub const sc = __LPC_MODULE(LPC_SC_TypeDef, SC_BASE);
pub const gpio0 = __LPC_MODULE(LPC_GPIO_TypeDef, GPIO0_BASE);
pub const gpio1 = __LPC_MODULE(LPC_GPIO_TypeDef, GPIO1_BASE);
pub const gpio2 = __LPC_MODULE(LPC_GPIO_TypeDef, GPIO2_BASE);
pub const gpio3 = __LPC_MODULE(LPC_GPIO_TypeDef, GPIO3_BASE);
pub const gpio4 = __LPC_MODULE(LPC_GPIO_TypeDef, GPIO4_BASE);
pub const wdt = __LPC_MODULE(LPC_WDT_TypeDef, WDT_BASE);
pub const tim0 = __LPC_MODULE(LPC_TIM_TypeDef, TIM0_BASE);
pub const tim1 = __LPC_MODULE(LPC_TIM_TypeDef, TIM1_BASE);
pub const tim2 = __LPC_MODULE(LPC_TIM_TypeDef, TIM2_BASE);
pub const tim3 = __LPC_MODULE(LPC_TIM_TypeDef, TIM3_BASE);
pub const rit = __LPC_MODULE(LPC_RIT_TypeDef, RIT_BASE);
pub const uart0 = __LPC_MODULE(LPC_UART0_TypeDef, UART0_BASE);
pub const uart1 = __LPC_MODULE(LPC_UART1_TypeDef, UART1_BASE);
pub const uart2 = __LPC_MODULE(LPC_UART_TypeDef, UART2_BASE);
pub const uart3 = __LPC_MODULE(LPC_UART_TypeDef, UART3_BASE);
pub const pwm1 = __LPC_MODULE(LPC_PWM_TypeDef, PWM1_BASE);
pub const i2c0 = __LPC_MODULE(LPC_I2C_TypeDef, I2C0_BASE);
pub const i2c1 = __LPC_MODULE(LPC_I2C_TypeDef, I2C1_BASE);
pub const i2c2 = __LPC_MODULE(LPC_I2C_TypeDef, I2C2_BASE);
pub const i2s = __LPC_MODULE(LPC_I2S_TypeDef, I2S_BASE);
pub const spi = __LPC_MODULE(LPC_SPI_TypeDef, SPI_BASE);
pub const rtc = __LPC_MODULE(LPC_RTC_TypeDef, RTC_BASE);
pub const gpioint = __LPC_MODULE(LPC_GPIOINT_TypeDef, GPIOINT_BASE);
pub const pincon = __LPC_MODULE(LPC_PINCON_TypeDef, PINCON_BASE);
pub const ssp0 = __LPC_MODULE(LPC_SSP_TypeDef, SSP0_BASE);
pub const ssp1 = __LPC_MODULE(LPC_SSP_TypeDef, SSP1_BASE);
pub const adc = __LPC_MODULE(LPC_ADC_TypeDef, ADC_BASE);
pub const dac = __LPC_MODULE(LPC_DAC_TypeDef, DAC_BASE);
pub const canaf_ram = __LPC_MODULE(LPC_CANAF_RAM_TypeDef, CANAF_RAM_BASE);
pub const canaf = __LPC_MODULE(LPC_CANAF_TypeDef, CANAF_BASE);
pub const cancr = __LPC_MODULE(LPC_CANCR_TypeDef, CANCR_BASE);
pub const can1 = __LPC_MODULE(LPC_CAN_TypeDef, CAN1_BASE);
pub const can2 = __LPC_MODULE(LPC_CAN_TypeDef, CAN2_BASE);
pub const mcpwm = __LPC_MODULE(LPC_MCPWM_TypeDef, MCPWM_BASE);
pub const qei = __LPC_MODULE(LPC_QEI_TypeDef, QEI_BASE);
pub const emac = __LPC_MODULE(LPC_EMAC_TypeDef, EMAC_BASE);
pub const gpdma = __LPC_MODULE(LPC_GPDMA_TypeDef, GPDMA_BASE);
pub const gpdmach0 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH0_BASE);
pub const gpdmach1 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH1_BASE);
pub const gpdmach2 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH2_BASE);
pub const gpdmach3 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH3_BASE);
pub const gpdmach4 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH4_BASE);
pub const gpdmach5 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH5_BASE);
pub const gpdmach6 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH6_BASE);
pub const gpdmach7 = __LPC_MODULE(LPC_GPDMACH_TypeDef, GPDMACH7_BASE);
pub const usb = __LPC_MODULE(LPC_USB_TypeDef, USB_BASE);
