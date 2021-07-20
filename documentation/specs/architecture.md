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
