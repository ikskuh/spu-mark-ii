# System Architecture

## Memory Map

This memory map documents the 24 bit address space attached to the MMU module:

| Start Address | End Address | Maps to / Function                            |
|---------------|-------------|-----------------------------------------------|
|    `0x000000` |  `0x00FFFF` | SPI ROM                                       |
|    `0x010000` |  `0x07FFFF` | *reserved for future ROM expansions*          |
|    `0x080000` |  `0x0FFFFF` | 512kB parallel RAM                            |
|    `0x100000` |  `0x100FFF` | Builtin 4kB highspeed RAM                     |
|    `0x101000` |  `0x1FFFFF` | *reserved for future highspeed RAM*           |
|    `0x20****` |  `0xEFFFFF` | *reserved for future use*                     |
|    `0xF00000` |  `0xF00FFF` | MMU configuration register                    |
|    `0xF01000` |  `0xF01FFF` | Builtin UART peripherial                      |
|    `0xF02000` |  `0xF02FFF` | Propeller Interface                           |
|    `0xF03000` |  `0xF04FFF` | VGA configuration register                    |
|    `0xF05000` |  `0xF0*FFF` | *reserved for future HW modules*              |

## Required memory bus features
- MMU: Caching with "all available memory left in the FPGA"
- multi master bus access for the 24 bit bus
- dynamic bus access times:
	- SPI ROM module is much slower than builtin block RAM.
	- is it possible to reduce fast access to single FPGA cycle?
- "cancel" semantics for bus access:
	- what happens if a bus master cancells its request?
	- VGA may access memory *too slow* for display (more than 166 ns cycle time)
- How to manage multi-byte accesses
	- Bus is only byte-accessed, translate 16 bit accesses into two accesses.
		- How to guarantee atomics for register updates?
	- Bus is both 16 and 8 bit wide, supports both kinds of access
		- more complex implementation for bus devices
	- what about the crazy VGA 4 byte register?
		=> update only on VSync?!

## MMU configuration register
See `simple-mmu.md` for configuration space description

## Builtin UART peripherial

Planned features:
- Fixed baud rate of 115200
- 8N1
- Status Register
- Receive Register
- Write Register
- 16 Byte Fifo

### Registers

| Offset  | Size | Access | Description           |
|---------|------|--------|-----------------------|
| `0x000` |    2 | R      | Status Register       |
| `0x002` |    2 | R      | Receive Data Register |
| `0x002` |    2 | W      | Write Data Register   |

#### Status Register

0: Receive Fifo Empty
1: Send Fifo Empty
2: Receive Fifo Full
3: Send Fifo Full
4: Frame Error
5: -
6: -
7: -

## Propeller SPI Interface

Planned features:
- Mass Storage Interface
	- "Read Block"
	- "Write Block"
	- "Get Device Info"
- Keyboard Interface
	- "Get Status"
	- "Read Keypress (FIFO)"
	- "Set LED Status"

## VGA configuration register

Planned features:
- Modes:
	- Graphic 128×128, 8bpp, 60 Hz
	- Graphic 256×128, 8bpp, 60 Hz
	- 40×30 Text Mode, Monochrome, 60 Hz (8×8 fixed character set)
- Palette support for RGB565
- Output signal is 320x240 with a border color
	> # 320x240 59.52 Hz (CVT 0.08M3) hsync: 15.00 kHz; pclk: 6.00 MHz
	> Modeline "320x240_60.00"    6.00  320 336 360 400  240 243 247 252 -hsync +vsync

### Registers

| Offset   | Size | Access | Description           |
|----------|------|--------|-----------------------|
| `0x0000` |    4 | R/W    | Framebuffer Address   |
| `0x0004` |    2 | R/W    | Border Color          |
| `0x0006` |    1 | R      | Status Register       |
| `0x0007` |    1 | W      | Control Register      |
| `0x1000` |    2 | R/W    | Palette Entry 0       |
| `0x1***` |    2 | R/W    | Palette Entry *       |
| `0x1FFE` |    2 | R/W    | Palette Entry 255     |

#### Framebuffer Address
Start address of the linear framebuffer. The frame buffer
is stored row-major, so the first 128 byte are the the first
row of pixels.

The address is in 24 bit address format, the upper 8 bit are
ignored by the VGA module. Also, the address is in physical
layout, so the memory must not be mapped to be visible.

#### Status Register

0,1: Mode
2:   VSync Active
3:   HSync Active

Mode:
	0=Off
	1=Text Mode
	2=128×128
	3=256×128

#### Control Register
Mirror register of the status register that allows writing
several control commands into the VGA.

0,1: Set Mode
1: N/A
2: N/A

