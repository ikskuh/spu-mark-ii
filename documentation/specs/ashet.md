# Ashet Home Computer Specification

**DISCLAIMER: This is a living document, do not take anything here for granted!**

## Hardware

### CPU

- SPU Mark II, a 16 bit processor

### Memory

- 8 MB of flash
- Up to 8 MB of ram

### Peripherials

- VGA video
- 3 serial ports
    - 2 * RS232
    - 1 * USB Serial
    - 1 infrared serial interface for wireless data transfers
- 2 PS/2 ports for keyboard and mouse
- 2 IDE slots for mass storage
- 2 (digital) joystick ports, compatible to c64/amiga/cpc/…
- IEEE 1284 II parallel port
- PCM audio interface
- Real time clock
- 10 MBit Ethernet
    - Possibly based on ENC28J60 or ENC624J600

## Memory Map

| Address Range | Memory Type     | Component                           |
|---------------|-----------------|-------------------------------------|
| `0x0*****`    | (*Memory*)      | up to 8 MB Flash ROM                |
| `0x7FE***`    | (*Peripherial*) | [I/O Page](ashet-register-space.md) |
| `0x7FF***`    | (*Peripherial*) | VGA Sprite Data                     |
| `0x80****`    | (*Memory*)      | up to 8 MB of RAM                   |

The [I/O Page](ashet-register-space.md) contains all peripherial registers and links to the peripherial devices.

## DMA Devices

The following devices have memory access (with priority top-to-bottom):

- VGA Controller
- Audio Controller
- CPU
- DMA Controller

## IRQ Table

| IRQ Number | Peripherial  |
|------------|--------------|
| 0          | `COM1`       |
| 1          | `COM2`       |
| 2          | `COM3`       |
| 3          | `COM4`       |
| 4          | `PER1`       |
| 5          | `PER2`       |
| 6          | `PCM`        |
| 7          | `DMA`        |
| 8          | `TIMER0`     |
| 9          | `TIMER1`     |
| 10         | `VGA`        |
| 11         | `ETHERNET`   |
| 11 … 31    | *unused*     |

## Serial Ports

| COM Name | Connector | Base Address |
|----------|-----------|--------------|
| `COM1`   | USB       | (TBD)        |
| `COM2`   | RS232 1   | (TBD)        |
| `COM3`   | RS232 2   | (TBD)        |
| `COM4`   | IR        | (TBD)        |

## PS/2 Ports

| Function | Connector | Base Address |
|----------|-----------|--------------|
| `PER1`   | KEYBOARD  | (TBD)        |
| `PER2`   | MOUSE     | (TBD)        |

## Timers and RTC

Timer 0 runs at 1 MHz, Timer 1 runs at 1 kHz.