# SPU Mark II - SOC Design

## CORE

## MMU

## RAM

## UART
Provides a 115200 Baud, 8N1 UART interface with a 16 byte fifo.
Access to registers is via 8 bit registers.

| Address | Register | Access |
|---------|----------|--------|
| 0x00    | Status   | RW     | 
| 0x01    | Send     | WO     |
| 0x02    | Receive  | RO     |

Status Word:

| Bit | Name | Meanign               |
|-----|------|-----------------------|
|   0 | TFE  | Transmit Fifo empty   | 
|   1 | TFF  | Transmit Fifo full    |
|   2 | RFE  | Receive Fifo empty    |
|   3 | RFF  | Receive fifo full     |
|   4 | FRE  | Frame error           |
|   5 | TFX  | Transmit fifo fault   |
|   6 | RFO  | Receive fifo overflow |
|   7 | RFX  | Receive fifo fault    |

Reading the status register will not modify any values.
Writing ones to `FRE`, `TFX`, `RFO` and `RFX` will reset those
bits to zero. Everything else will stay unchanged.

Writing a byte into "send" register will append that byte to
the send fifo. if the send fifo is full, the byte written
will be discarded and the `TFX` flag will be set.

Reading a byte from the "receive" register will read a byte
from the receive fifo. If the fifo is empty when reading,
the `RFX` will be set and zero will be returned.

When the UART transmit fifo is not empty, it will start to
transmit the bytes to the serial line. This will be done until
the fifo is empty again.

When the UART receives a byte via the serial line, it will be
put into the receive fifo. If the receive fifo is full, the
byte will be discarded and the `RFO` flag will be set in the
status register.

## I²C

## DEBUG
