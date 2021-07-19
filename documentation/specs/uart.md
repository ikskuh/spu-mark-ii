# Builtin UART peripherial

Planned features:
- Status Register
- Receive Register
- Write Register
- 16 Byte Fifo

## Registers

| Offset  | Size | Access | Description           |
|---------|------|--------|-----------------------|
| `0x000` |    2 | R      | Status Register       |
| `0x002` |    2 | R      | Receive Data Register |
| `0x002` |    2 | W      | Write Data Register   |
| `0x004` |    2 | R/W    | Control Register      |
| `0x006` |    2 | R/W    | Baudrate Register     |

### Status Register

0: Receive Fifo Empty
1: Send Fifo Empty
2: Receive Fifo Full
3: Send Fifo Full
4: Frame Error
5: -
6: -
7: -

### Control Register

…

### Baudrate Register

## FIFO

Both read and write side have a 16 byte fifo in place that temporarily buffers values and allows delay receive and bulk send.