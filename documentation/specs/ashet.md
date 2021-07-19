# Ashet Home Computer Specification

## Hardware

### CPU

- SPU Mark II, a 16 bit processor

### Memory

- 8 MB of flash
- Up to 8 MB of ram

### Peripherials

- VGA video
- 2 serial ports
- 1 infrared serial interface for wireless data transfers
- 2 PS/2 ports for keyboard and mouse
- 2 IDE slots for mass storage
- 2 joystick ports, compatible to c64/amiga/cpc/…
- 10 MBit Ethernet
  - Possibly based on ENC28J60 or ENC624J600
- IEEE 1284 II parallel port
- PCM audio interface
- Real time clock

## Memory Map
- `0x0*****`: ~8 MB Flash ROM
- `0x7F0***`: (*Peripherial*) MMU Control/Status
- `0x7F1***`: (*Peripherial*) IRQ Controller
- `0x7F2***`: (*Peripherial*) UART'0
- `0x7F3***`: (*Peripherial*) UART'1
- `0x7F4***`: (*Peripherial*) PS/2'1 (Keyboard)
- `0x7F5***`: (*Peripherial*) PS/2'2 (Mouse)
- `0x7F6***`: (*Peripherial*) SDIO'1
- `0x7F7***`: (*Peripherial*) SDIO'2
- `0x7F8***`: (*Peripherial*) Timer + RTC
- `0x7F9***`: (*Peripherial*) IrDA Interface
- `0x7FA***`: (*Peripherial*) Joystick Interface + Parallel Port
- `0x7FB***`: (*Peripherial*) PCM Audio Control/Status
- `0x7FC***`: (*Peripherial*) DMA Control/Status
- `0x7FD***`: (*Peripherial*) VGA Control/Status
- `0x7FE***`: (*Peripherial*) VGA Palette
- `0x7FF***`: (*Peripherial*) VGA Sprite Data
- `0x80****`: (*Memory*) 512k RAM
- `0x88****`: (*Unused*)

## DMA Devices

The following devices have memory access (with priority top-to-bottom):
- VGA Controller
- Audio Controller
- CPU
- DMA Controller

## Components

### VGA
- Do not only add framebuffer address, but also framebuffer stride (scrolling!)
