Planned features:
- Modes:
	- Graphic 128×128, 8bpp, 60 Hz
	- Graphic 256×128, 8bpp, 60 Hz
	- 40×30 Text Mode, Monochrome, 60 Hz (8×8 fixed character set)
- 256 color palette support for RGB565
- Output signal is 640x480 with double scaling and a border color
	> ```
	> # 640x480 59.38 Hz (CVT 0.31M3) hsync: 29.69 kHz; pclk: 23.75 MHz
	> Modeline "640x480_60.00"   23.75  640 664 720 800  480 483 487 500 -hsync +vsync
	> ```

## Registers

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



> This document isn't written yet. Please consider this not even a working draft.

Fakten:
- 4096 Byte Platz
- 16 × 16²-Sprites mit 8 bpp

```
struct SpriteDef {
	word pixeldata_addr;
	word next_sprite_addr;
	sword x;
	sbyte y;
	byte config; // [ w: u4, h: u4 ]
}
```

width  = u4 & "00"
height = u4 & "00"

