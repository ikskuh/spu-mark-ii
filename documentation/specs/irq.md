# IRQ Controller

Planned features:
- Dispatch multiple IRQ lanes into a single lane
- Acknowledge of IRQs
- Masking of IRQs
- up to 32 IRQs

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    2 | R      | Active IRQs 0…15       |
| `0x002` |    2 | R      | Active IRQs 16…31      |
| `0x000` |    2 | W      | Acknowledge IRQs 0…15  |
| `0x002` |    2 | W      | Acknowledge IRQs 16…31 |
| `0x004` |    2 | R/W    | Mask IRQs 0…15         |
| `0x006` |    2 | R/W    | Mask IRQs 16…31        |