# SPU Mark II - Primitive Bank Unit

## Overview
- 16 bit virtual addresses
- 24 bit physical addresses
- 256 MMU / interrupt contexts (cpu state + mmu config)
- 16 banks a 4096 byte -> 64 kB address space
- Provides interrupt handling

## Configuration
The MMU configuration is mapped into the physical address
space at a system-defined location and has the
following layout:

| Offset  | Size | Description     |
|---------|------|-----------------|
| `0x000` |    2 | Page 0 Descriptor  |
| `0x002` |    2 | Page 1 Descriptor  |
| `0x004` |    2 | Page 2 Descriptor  |
| `0x006` |    2 | Page 3 Descriptor  |
| `0x008` |    2 | Page 4 Descriptor  |
| `0x00A` |    2 | Page 5 Descriptor  |
| `0x00C` |    2 | Page 6 Descriptor  |
| `0x00E` |    2 | Page 7 Descriptor  |
| `0x010` |    2 | Page 8 Descriptor  |
| `0x012` |    2 | Page 9 Descriptor  |
| `0x014` |    2 | Page 10 Descriptor |
| `0x016` |    2 | Page 11 Descriptor |
| `0x018` |    2 | Page 12 Descriptor |
| `0x01A` |    2 | Page 13 Descriptor |
| `0x01C` |    2 | Page 14 Descriptor |
| `0x01E` |    2 | Page 15 Descriptor |

Each page descriptor is 16 bit wide and organized in
the following manner:

