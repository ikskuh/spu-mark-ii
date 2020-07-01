# The SPU Mark II Project

A project that focuses on the development and improvement of the *SPU Mark II* instruction
set architecture.

Another focus is development and creation of a concrete implementation of the CPU in VHDL
as well as building a small "home computer" around an FPGA board similar to other computers
from the 80ies.

## SPU Mark II

<img align="right" src="./documentation/spu-mk-ii-logo-small.png">

The SPU Mark II is a 16 bit *RISC*ish cpu that uses the [stack machine](https://en.wikipedia.org/wiki/Stack_machine)
approach instead of a [register machine](https://en.wikipedia.org/wiki/Register_machine) approach.

The instrution set is documented in [documentation/isa.md](documentation/isa.md).

Short feature list:
- Highly flexible instruction set
- Conditional instructions instead of special conditional jumps or movs
- Optional hardware multiplication/division units (WIP)
- Optional interrupt handling (WIP)

To get a feel for the instruction set, here's a small example for a `void puts(char*str)` function:

```asm
puts:
	bpget ; function prologue
	spget
	bpset
	
	get 2 ; fetch arg 1
puts_loop:
	ld8 [i0:peek] [f:yes]
	[ex:nonzero] st8 0x4000     ; Use MMIO for text output
	[ex:nonzero] add 1
	[ex:nonzero] jmp puts_loop
	pop

	bpget ; function epilogue
	spset
	bpset
	ret
```

## Ashet Home Computer
The *Ashet Home Computer* is a computer built on top of the *SPU Mark II* cpu and
provides a small environment to use the cpu.

### Planned Features
- [MMU](documentation/specs/mmu.md)
- Video Output (either FBAS or VGA)
- Audio Output (signed 16 bit PCM)
- SD Card Storage
- Keyboard Interface
- Joystick Port (C64 style)
- UART interface

### Current Memory Map

Note that this memory map right now does not utilize the MMU, so bus width is 16 bit.

| Range               | Function           |
|---------------------|--------------------|
| `0x0000` … `0x3FFF` | Builtin ROM        |
| `0x4000` … `0x4FFF` | UART Interface     |
| `0x6000` … `0x60FF` | 256 byte fast RAM  |
| `0x6100` … `0x7FFF` | *Unmapped*         |
| `0x8000` … `0xFFFF` | 32k byte slow RAM  |
