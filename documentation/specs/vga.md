# BasicVGA

Planned features:

- Modes:
	- Graphic 256×128, 8bpp, 60 Hz
	- (*planned*) Graphic, 2bpp, 60 Hz
- 256 color palette support for RGB565
- Output signal is 640x480 with double scaling and a border color

```
# 640x480 59.38 Hz (CVT 0.31M3) hsync: 29.69 kHz; pclk: 23.75 MHz
Modeline "640x480_60.00"   23.75  640 664 720 800  480 483 487 500 -hsync +vsync
```

# Registers

| Offset   | Size | Access | Description           |
|----------|------|--------|-----------------------|
| `0x0000` |    4 | R/W    | Framebuffer Address   |
| `0x0004` |    2 | R/W    | Border Color          |
| `0x0006` |    1 | R      | Status Register       |
| `0x0007` |    1 | W      | Control Register      |
| `0x1000` |    2 | R/W    | Palette Entry 0       |
| `0x1***` |    2 | R/W    | Palette Entry *       |
| `0x1FFE` |    2 | R/W    | Palette Entry 255     |

## Framebuffer Address
Start address of the linear framebuffer. The frame buffer
is stored row-major, so the first 128 byte are the the first
row of pixels.

The address is in 24 bit address format, the upper 8 bit are
ignored by the VGA module. Also, the address is in physical
layout, so the memory must not be mapped to be visible.

## Status Register

- 0: HighRes
- 1: *unused*
- 2: VSync Active
- 3: HSync Active

When *HighRes* is `1`, the graphic mode is switched from 256×128,8bpp to 512×256,2bpp. In this mode, only 4 colors are available, but the size is horizontally and vertically doubled.

## Control Register
Mirror register of the status register that allows writing several control commands into the VGA.

- 0: HighRes
- 1: *unused*
- 2: N/A
- 3: N/A

# Sprite Unit

**This part of the document isn't written yet. Please consider this not even a working draft.**

The sprite unit is a built into two parts:

- A 4096 byte memory section that stores both sprite pixels and sprite definitions
- A set of registers that enable up to 8 sprites

Facts:

- 4096 byte storage for sprite data (one page)
- Sprite size can be set in steps of 4 pixels width and height
- Sprite size can be from 4×4 to 64×64 pixels.
- Sprites always use 255 colors from the palette, color 0 is transparent

```c
struct SpriteDef {
	u16 pixeldata_addr;
	u16 next_sprite_addr;
	i16 x;
	i8  y;
	u4 width;
	u4 height;
}
```

width  = u4 & "00"
height = u4 & "00"

