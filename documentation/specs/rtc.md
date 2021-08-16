# RTC

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    1 | R      | Current Day            |
| `0x001` |    1 | R      | Current Month          |
| `0x002` |    2 | R      | Current Year           |
| `0x004` |    1 | R      | Current Hour           |
| `0x005` |    1 | R      | Current Minute         |
| `0x006` |    1 | R      | Set Data Day           |
| `0x007` |    1 | R      | Set Data Month         |
| `0x008` |    2 | R      | Set Data Year          |
| `0x00A` |    1 | R      | Set Data Hour          |
| `0x00B` |    1 | R      | Set Data Minute        |
| `0x00C` |    2 | RW     | Control Register       |

### `Control Register`

| Bit Range | Description                                            |
|-----------|--------------------------------------------------------|
|     `[0]` | Write to `1` to write the time. Will always read as 0. |
|  `[15:1]` | *reserved*, must be 0                                  |