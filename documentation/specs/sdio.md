# SDCard Controller

Planned features:
- Communicate with a single SD card
- One controller per device

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    2 | R      | Status Reqister        |
| `0x002` |    2 | R/W    | Control Reqister       |
| `0x004` |    2 | R/W    | Block Address (Low)    |
| `0x006` |    2 | R/W    | Block Address (High)   |
| `0x008` |    2 | R      | Block Count (Low)      |
| `0x00A` |    2 | R      | Block Count (High)     |
| `0x200` |  512 | R/W    | Block Data             |

### Status Register

0: Device present
1: Device initialized
2: Operation in progress
3: Operation faulted
4: Operation successful

### Control Reqister

0: Initialize card
1: Read Block
2: Write block

### Block Address (Low)
Lower two bytes of the 32 bit block address.

### Block Address (High)
Upper two bytes of the 32 bit block address.

### Block Count (Low)
Lower two bytes of the 32 bit total block count of the sd card.

If the card was not properly initialized, this register contains invalid data.

### Block Count (High)
Upper two bytes of the 32 bit total block count of the sd card.

If the card was not properly initialized, this register contains invalid data.

### Block Data

512 byte that will be read from the SD card or will be written to it.