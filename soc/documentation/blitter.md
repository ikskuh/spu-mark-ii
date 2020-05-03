# RAM Blitter

TODO:
- blitter finished irq
- vector fill
	- How to solve "xor" with color values?
	- filler-line must "kill" previous lines for *Vector Fill* to work

The RAM Blitter is a DMA unit that is developed for general purpose DMA transfers, as well as framebuffer modifications. It supports basic linear memory transfers as well as rectangle copies with image manipulation.

The RAM blitter also has a modes for drawing 2d vector graphics and a filling operation that allows color transfers.

## Draw Lists

The RAM Blitter has a linked-list design to process a sequence of commands instead of accepting single commands.

The supported commands are:
- Copy Rectangle
- Paint Primitives (Point, Line, Circle, Triangle)
- Vector Fill

Each draw list entry starts with a shared configuration part that defines part of the linked list and some common flags:

| Offset | Size | Description                             |
|--------|------|-----------------------------------------|
| 0      | 3    | Pointer to the next element in the list |
| 3      | 1    | Flags                                   |

The flags define one bit right now:

| Bit     | Description                                   |
|---------|-----------------------------------------------|
| `[3:0]` | Operation                                     |
| `[7:4]` | *reserved*                                    |

*Operation* is one of the following values and define the type of operation that will be performed when reading this node:

| Value    | Name            | Description                                       |
|----------|-----------------|---------------------------------------------------|
| `"0000"` | End of List     | If this operation is encountered, the RAM Blitter will stop following the linked list and emit an IRQ signal. |
| `"0001"` | Copy Rect       | This node describes a *Copy Rect* operation.      |
| `"0010"` | Vector Fill     | This node describes a *Vector Fill* operation     |
| `"0011"` | *reserved*      |                                                   |
| `"0100"` | *reserved*      |                                                   |
| `"0101"` | *reserved*      |                                                   |
| `"0110"` | *reserved*      |                                                   |
| `"0111"` | *reserved*      |                                                   |
| `"1000"` | Paint Primitive | This node describes a *Paint Point* operation.    |
| `"1001"` | Paint Primitive | This node describes a *Paint Line* operation.     |
| `"1010"` | Paint Primitive | This node describes a *Paint Triangle* operation. |
| `"1011"` | Paint Primitive | This node describes a *Paint Circle* operation.   |
| `"1100"` | *reserved*      |                                                   |
| `"1101"` | *reserved*      |                                                   |
| `"1110"` | *reserved*      |                                                   |
| `"1111"` | *reserved*      |                                                   |


## Copy Rect

The *Copy Rect* operation will read data from a source rectangle and will copy it to a destination rectangle.
While copying, both an alpha operation as well as a masking operation can be performed.

### Operation

**Inputs:**
- Alpha (byte)
- Source (rectangle)
- Destinaction (rectangle)
- Mask (rectangle)
- Alpha Function
- Pixel Function

This operation will copy bytes from a *source* rectangle into *destination* rectangle in memory. *Alpha* together with the *Alpha Function* determine which bytes are actually copied, while *mask* determines which portion of the byte is copied. The *Pixel Function* will be applied to each copied byte before applying the mask.

Rectangles are a pointers that will be incremented by 1 for each pixel in a row of the rectangle. After *width* pixels, the start of the row will be incremented by *stride* bytes. This will be repeated for the *height* of the rectangle. While copying, when coordinates overflow in the *source* or *mask* rectangle, they will wrap around to the start of the row or rectangle, allowing smaller portions of ram to be copied repeatedly.

This allows a versatile set of operations to be performed with the RAM Blitter:

- Copy a linear portion of RAM
- Fill a linear portion of RAM
- Copy a rectangular portion of RAM
- Fill a rectangular portion of RAM with a pattern
- Copy a sprite with transparent pixels into a frame buffer
- Enable color cycling with the mask and pixel operations
- …

The operation that happens in detail is the following:

```
fetch alpha
foreach addr in dst:
	pixel ← fetch src
	if alpha-func(pixel, alpha):
		pixel ← pixel-func(pixel)
		if mask-enabled:
			fetch mask
			if mask != 0xFF:
				fetch dst
				pixel ← (pixel & mask) & (dst & ~mask)
				write pixel → dst
		else
			write pixel → dst
```

Each fetch follows the following logic:
```py
fetch-result ← memory(work-ptr)
work-ptr += 1
x += 1
if x == w:
	work-ptr += (stride - w)
	x = 0
	y += 1
	if y == h:
		work-ptr = rectangle-ptr
		y = 0
```

### Data Structures

The *Copy Rect* list node has the following structure:

| Offset | Size | Description                             |
|--------|------|-----------------------------------------|
| 0      | 3    | Pointer to the next element in the list |
| 3      | 1    | Flags                                   |
| 4      | 1    | Alpha                                   |
| 5      | 1    | Functions                               |
| 6      | 10   | Source Rectangle                        |
| 16     | 10   | Mask Rectangle                          |
| 26     | 10   | Destination Rectangle                   |

Each rectangle is encoded as this:

| Offset | Size | Description                             |
|--------|------|-----------------------------------------|
| 0      | 3    | Pointer to the pixel data               |
| 3      | 1    | *reserved*                              |
| 4      | 2    | Stride between scanlines                |
| 6      | 2    | Width of the rectangle in pixels        |
| 8      | 2    | Height of the rectangle in pixels       |


The byte in the *Functions* field is organized as a bit field:

| Range   | Description            |
|---------|------------------------|
| `[2:0]` | Alpha Function         |
| `[3]`   | *reserved*             |
| `[6:4]` | Pixel Function         |
| `[7]`   | Enable *Mask* when `1` |

The *Alpha Function* has the following options:

| Value   |                                |
|---------|--------------------------------|
| `"000"` | Copy always                    |
| `"001"` | Copy when `alpha != src-pixel` |
| `"010"` | Copy when `alpha == src-pixel` |
| `"011"` | Copy when `alpha >= src-pixel` |
| `"100"` | Copy when `alpha <= src-pixel` |
| `"101"` | Copy when `alpha <  src-pixel` |
| `"110"` | Copy when `alpha >  src-pixel` |
| `"111"` | *reserved*                     |

The *Pixel Function* has the following options:

| Value   |                                |
|---------|--------------------------------|
| `"000"` | Copy pixel value               |
| `"001"` | Increment pixel value          |
| `"010"` | Decrement pixel value          |
| `"011"` | Bitwise invert pixel value     |
| `"100"` | Clear pixel value to `0x00`    |
| `"101"` | Set pixel value to `0xFF`      |
| `"110"` | *reserved*                     |
| `"111"` | *reserved*                     |

## Paint Primitive

The *Paint Primitive* operation draws a list of 2D primitives, namely points, lines, circles and triangles.

**Inputs:**
- Source (Pointer+Stride)
- Count (Word)
- Type (point/line/tris/circ)
- Mode (filled/outline/filler-line)

Each primitive is composed of a number of xy-coordinates and one or two colors and are separated by *stride* bytes.

todo:
	- xy-commands relative to what? how to efficiently calculate memory offsets?


type=line
cnt = 4
src = stride=10, [
	 10, 0,  10, 0, 100, 0,  10, 0, C, ?,
	100, 0,  10, 0, 100, 0, 100, 0, C, ?,
	100, 0, 100, 0,  10, 0, 100, 0, C, ?,
	 10, 0, 100, 0,  10, 0,  10, 0, C, ?,
]


### Data Structures

The *Paint Primitive* list node has the following structure:

| Offset | Size | Description                             |
|--------|------|-----------------------------------------|
| 0      | 3    | Pointer to the next element in the list |
| 3      | 1    | Flags                                   |
| 4      | 3    | Pointer to the array of elements        |
| 7      | 1    | Element Type and Paint Mode             |
| 8      | 2    | Primitive Count                         |

Byte 7 is a bit field:

| Range   | Name           | Description                                |
|---------|----------------|--------------------------------------------|
| `[2:0]` | Primitive Type | Defines the primitive that is drawn        |
| `[3]`   | *reserved*     |                                            |
| `[5:4]` | Paint Mode     | Defines how the primitives should be drawn |
| `[7:5]` | *reserved*     |                                            |

**Primitive Type:**

| Value   | Description                                                 |
|---------|-------------------------------------------------------------|
| `"000"` | Point                                                       |
| `"001"` | Line                                                        |
| `"010"` | Triangle                                                    |
| `"011"` | Circle                                                      |
| `"1**"` | *reserved*                                                  |

**Paint Mode:**

| Value  | Description                                                             |
|--------|-------------------------------------------------------------------------|
| `"00"` | The primitives will be drawn as outlines.                               |
| `"01"` | *reserved*                                                              |
| `"10"` | The primitive will be filled with its color                             |
| `"11"` | The primitive outline will be drawn with another color than its content |

## Vector Fill

Similar to amiga filler: Toggle filling mode on and off when a certain color value is detected

Params:
	src   : rect[ptr,stride,w,h]
	dst   : rect[ptr,stride,w,h]
	color : rect[ptr,stride,w,h]
	on    : color
	off   : color
	mode  : inclusive/exclusive


### Data Structures

The *Vector Fill* list node has the following structure:

| Offset | Size | Description                             |
|--------|------|-----------------------------------------|
| 0      | 3    | Pointer to the next element in the list |
| 3      | 1    | Flags                                   |