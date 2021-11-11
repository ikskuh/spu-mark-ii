# List of Syscalls

## Serial Port

- setup (baud, ...)
- status
- write char
- read char

## Raw Mass Storage / Disk

- detect
- read sector
- write sector

## File System I/O

- stat
- dir
- open
- read
- write
- close
- mkdir
- delete
- truncate
- move
   
## Display:

- clear
- loadPalette
- loadBitmap
- loadImage
- printString
- moveCursor
- verticalScroll
- horizontalScroll
- setBorderColor
- enableCursor

## Parallel Port

- set direction
- write
- read

## Keyboard

- status
- read char
- get key

## Mouse

- status
- readPos
- show
- hide

## Joystick

- read

## RTC

- read
- write
- read time
- write time
- read date
- write date

## Memory

- status
- alloc page
- free page

## Tasks

- spawn
- kill
- status
- yield
- sleep
- send
- receive