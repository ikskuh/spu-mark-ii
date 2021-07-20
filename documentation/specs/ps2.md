# PS/2 Controller

Planned features:
- Communicate with a PS/2 device (mouse, keyboard)
- One controller per device

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    2 | R      | Status Reqister        |
| `0x002` |    2 | R      | Data Input             |
| `0x002` |    2 | W      | Data Output            |

### Status Register

0: Device Present
1: Input FIFO not full
2: Input FIFO full
3: Output FIFO not full
4: Output FIFO full

### Data Input

Reading from this port either returns the value read or all bits set if no value is present in the input fifo.

### Data Output

Writing to this port will either put a byte into the send fifo if not full or discard the value.