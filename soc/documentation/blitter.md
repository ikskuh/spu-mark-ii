# RAM Blitter

TODO:
- blitter finished irq

## Draw Lists

All operations can be linked together with a linked
list.

## Operations

- Copy Rect
- Primitive Painter
	- Line Drawer
	- Circle Drawer
	- Triangle Drawer
- Vector Filler

### Copy Rect

Copies a rect with masking and alpha testing

Params:
	alpha : color
	src   : rect [ptr,stride,w,h]
	mask  : rect [ptr,stride,w,h]
	dst   : rect [ptr,stride,w,h]
	alpha-func: !=, ==, >=, <=, >, <, true
	pixel-func: cpy/inc/dec/inv/clr/fill

Copy Rect Pipeline:
	fetch src
	fetch alpha
	if alpha-func(src, alpha):
		src = apply pixel-func
		fetch mask
		src = src & mask
		write src → dst

## Primitive Painter

Draws filled or unfilled primitives

TODO: How to solve "xor" with color values?
filler-line must "kill" previous lines for vector filler to work

Params:
	src  : [ptr,stride]
	cnt  : word
	type : point/line/tris/circ
	mode : filled/outline/filler-line

type=line
cnt = 4
src = stride=10, [
	 10, 0,  10, 0, 100, 0,  10, 0, C, ?,
	100, 0,  10, 0, 100, 0, 100, 0, C, ?,
	100, 0, 100, 0,  10, 0, 100, 0, C, ?,
	 10, 0, 100, 0,  10, 0,  10, 0, C, ?,
]

## Vector Filler

Similar to amiga filler: Toggle filling mode
on and off when a certain color value is detected

Params:
	src   : rect[ptr,stride,w,h]
	dst   : rect[ptr,stride,w,h]
	color : rect[ptr,stride,w,h]
	on    : color
	off   : color
	mode  : inclusive/exclusive

