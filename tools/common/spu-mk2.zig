pub const ExecutionCondition = enum(u3) {
    always = 0,
    when_zero = 1,
    not_zero = 2,
    greater_zero = 3,
    less_than_zero = 4,
    greater_or_equal_zero = 5,
    less_or_equal_zero = 6,
    undefined0,
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
