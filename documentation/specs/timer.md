# Timer

Each timer runs at a defined frequency that is not necessarily the cpu frequency.

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    2 | RW     | Timer Value            |
| `0x002` |    2 | RW     | Timer Limit            |
| `0x004` |    2 | RW     | Prescaler              |
| `0x006` |    2 | RW     | Control                |

`Timer Value` increments each time `Prescaler`-1 clocks have happened. When `Timer Value` reaches `Timer Limit`, the `Timer Value` is reset to 0 and a IRQ is raised if enabled.

### Status / Control

| Bit Range | Description           |
|-----------|-----------------------|
|     `[0]` | Enable Timer          |
|     `[1]` | Enable IRQ            |
|  `[15:2]` | *reserved*, must be 0 |