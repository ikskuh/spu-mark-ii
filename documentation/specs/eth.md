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

| Bit Range | Name  |Access | Description                                            |
|-----------|-------|-------|--------------------------------------------------------|
|     `[0]` | `ENA` | RW    | If `1`, the ethernet interface is enabled.             |
|     `[1]` | `FLT` | RW    | If `1`, only ethernet packets with the correct MAC address will be received. Otherwise, all packets will be received. |
|     `[2]` | `RTR` | RO    | A packet is ready in the queue and can be read via the `Receive Data Register`. |
|     `[3]` | `RAK` | RW    | Acknowledge received packet. Write this bit to `1` to signal that the incoming packet was fully processed and a new one can be provided if available. |
|     `[4]` | `SND` | RW    | After bytes are written into `Send Data Register`, write `1` to signal that the packet should be sent. |
|     `[5]` | `SLF` | RW    | Write `1` to this register to flush the send buffer and discard all bytes written. |
|     `[6]` | `PME` | R     | Is `1` when the packet is for the local MAC address    |
|     `[7]` | `PMC` | R     | Is `1` when the packet has a multicast MAC address.    |
|     `[8]` | `PBC` | R     | Is `1` when the packet has a broadcast MAC address.    |
|  `[15:9]` |       | *reserved*, must be 0                                          |

### `Receive Packet Length`

When a incoming packet is signalled via the `RTR` bit, this register will contain the remaining bytes of the packet to be read.

Each read on the `Receive Data Register` will decrement this value until it reaches 0.

### `Send Packet Length`

Contains the current number of bytes written into the `Send Data Register`. If 0, no bytes are currently in the send buffer.

### `Interface MAC address`

These six byte contain the MAC address of the ethernet interface.