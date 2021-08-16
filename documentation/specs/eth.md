# Ethernet Interface

## Registers

| Offset  | Size | Access | Description            |
|---------|------|--------|------------------------|
| `0x000` |    1 | R      | Receive Data Register  |
| `0x000` |    1 | W      | Send Data Register     |
| `0x002` |    2 | RW     | Control/Status         |
| `0x004` |    2 | R      | Receive Packet Length  |
| `0x006` |    2 | R      | Send Packet Length     |
| `0x008` |  6*1 | R      | Interface MAC address  |

### `Control/Status`

| Bit Range | Name  |Access | Description                                                                                            |
|-----------|-------|-------|--------------------------------------------------------------------------------------------------------|
|     `[0]` | `ENA` | RW    | If `1`, the ethernet interface is enabled.                                                             |
|     `[1]` | `FUC` | RW    | If `1`, unicast ethernet packets with a foreign MAC will be filtered.                                  |
|     `[2]` | `FMC` | RW    | If `1`, multicast ethernet packets will be filtered.                                                   |
|     `[3]` | `FBC` | RW    | If `1`, broadcast ethernet packets will be filtered.                                                   |
|     `[4]` | `RTR` | RO    | A packet is ready in the queue and can be read via the `Receive Data Register`.                        |
|     `[5]` | `RAK` | RW    | Acknowledge received packet. Write this bit to `1` to signal that the incoming packet was fully processed and a new one can be provided if available. |
|     `[6]` | `SND` | RW    | After bytes are written into `Send Data Register`, write `1` to signal that the packet should be sent. |
|     `[7]` | `SFL` | RW    | Write `1` to this register to flush the send buffer and discard all bytes written.                     |
|     `[8]` | `PME` | R     | Is `1` when the currently ready receive packet is for the local MAC address                            |
|     `[9]` | `PMC` | R     | Is `1` when the currently ready receive packet has a multicast MAC address.                            |
|    `[10]` | `PBC` | R     | Is `1` when the currently ready receive packet has a broadcast MAC address.                            |
| `[15:11]` |       |       | *reserved*, must be 0                                                                                  |

### `Receive Packet Length`

When a incoming packet is signalled via the `RTR` bit, this register will contain the remaining bytes of the packet to be read.

Each read on the `Receive Data Register` will decrement this value until it reaches 0.

### `Send Packet Length`

Contains the current number of bytes written into the `Send Data Register`. If 0, no bytes are currently in the send buffer.

### `Interface MAC address`

These six byte contain the MAC address of the ethernet interface.