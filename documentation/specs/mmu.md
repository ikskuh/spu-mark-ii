# SimpleMMU

## Overview
- 16 bit virtual addresses
- 24 bit physical addresses
- 16 banks a 4096 byte -> 64 kB address space

## Function
The MMU translates virtual addresses in a physical addresses by utilizing 16 pages.

Each page contains 4096 bytes of memory which can be write-protected.

The physical address for a memory access is created by looking up the upper 12 bit in the page descriptor and taking the lower 12 bit of the virtual address:

```
physical[23:12] := mmuConfig[virt[15..12]][15..4]
physical[11:0]  := virt[11..0]
```

When a non-enabled page is accessed, the MMU raises a fault signal and sets the corresponding bit in the Page Fault Register.

When a non-writeable page is beeing written, the MMU raises a fault signal and sets the corresponding bit in the Write Fault Register.

## Configuration
The MMU configuration is mapped into the physical address space at a system-defined location and has the following layout:

| Offset  | Size | Access | Description           |
|---------|------|--------|-----------------------|
| `0x000` |    2 | R/W    | Page 0 Descriptor     |
| `0x002` |    2 | R/W    | Page 1 Descriptor     |
| `0x004` |    2 | R/W    | Page 2 Descriptor     |
| `0x006` |    2 | R/W    | Page 3 Descriptor     |
| `0x008` |    2 | R/W    | Page 4 Descriptor     |
| `0x00A` |    2 | R/W    | Page 5 Descriptor     |
| `0x00C` |    2 | R/W    | Page 6 Descriptor     |
| `0x00E` |    2 | R/W    | Page 7 Descriptor     |
| `0x010` |    2 | R/W    | Page 8 Descriptor     |
| `0x012` |    2 | R/W    | Page 9 Descriptor     |
| `0x014` |    2 | R/W    | Page 10 Descriptor    |
| `0x016` |    2 | R/W    | Page 11 Descriptor    |
| `0x018` |    2 | R/W    | Page 12 Descriptor    |
| `0x01A` |    2 | R/W    | Page 13 Descriptor    |
| `0x01C` |    2 | R/W    | Page 14 Descriptor    |
| `0x01E` |    2 | R/W    | Page 15 Descriptor    |
| `0x020` |    2 | RO     | Page Fault Register   |
| `0x022` |    2 | RO     | Write Fault Register  |

Each page descriptor is 16 bit wide and organized in the following manner:

| Bit Range | Name   | Description                           |
| --------- | ------ | ------------------------------------- |
| `[0]`     | **EN** | page mapping enabled                  |
| `[1]`     | **WP** | page is write protected               |
| `[2]`     | **CA** | caching is enabled for this page      |
| `[3]`     |        | reserved, must be `0`                 |
| `[15:4]`  | **PA** | Upper 12 bits of the physical address |

The Page Fault Register contains a bit for each page that flags if there was an access fault (page not mapped).

The Write Fault Register contains a bit for each page that flags if there was a write fault (page was written, but write protected).

Each Page Fault Register and Write Fault Register are beeing cleared to 0 after a read operation.

## I/Os

- 24 output physical address lanes
- 16 input virtual address lanes
- 16 in/out data lanes to the bus
- RE, WE input signal (from CPU)
- RE, WE output signal (to Bus)
- CS input to activate read-write access to the MMU

## Changelog

### v1.0
- Initial version

