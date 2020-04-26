
Fakten:
- 4096 Byte Platz
- 16 * 16²-Sprites mit 8 bpp

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

