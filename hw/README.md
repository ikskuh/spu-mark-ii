# The *SPU Mark II* PC

## Project Goal

Build a physical computer that runs with a *SPU Mark II*.

## Milestones

1. Create textual system architecture
2. Create PCB schematic for
   - Main Board
   - RAM Board
   - Flash Board
   - UART I/O-Card
   - DipSwitch-ROM®
3. Create PCB layout for those boards
4. Build boards
5. Write software!

## Hardware

FPGA: 10M25SCE144C8G
C8G => SC (Single Supply, no analog), E144 (eqfp144), Consumer Grade, Low Speed,

## System Architecture

### SPU

See *isa.md* for architectural description.

### MMU

See *simple-mmu.md* for architectural description.

### BUS

The bus connects the **MMU** with external devices. It features 24 bit addresses, 16 bit data transfers with the possibility to access device memory with either byte access or word access. It also features the possibility to delay a memory transfer until a device is ready.

The bus uses 48 physical lanes which are defined in the following table:

| Lane       | Direction      | Description                                                  |
| ---------- | -------------- | ------------------------------------------------------------ |
| `GND`      | -              | Signal Ground                                                |
| `VCC`      | -              | Voltage Supply                                               |
| `A1`…`A23` | Output         | Address lanes for word address                               |
| `BLS0#`    | Output         | Byte lane select 0. Selects the lower byte of the addressed word |
| `BLS1#`    | Output         | Byte lane select 1. Selects the upper byte of the addressed word |
| `D0`…`D7`  | Bi-Di          | Lower byte data lanes                                        |
| `D8`…`D15` | Bi-Di          | Upper byte data lanes                                        |
| `RE#`      | Output         | Read enable. Requests a transfer from Device → CPU.          |
| `WE#`      | Output         | Write enable. Requests a transfer                            |
| `HOLD#`    | Input          | If signaled **L**, the bus needs to keep its state until `HOLD` is **H** again. |
|            |                | Reserved                                                     |
|            |                | Reserved                                                     |

Devices connected to the bus must keep `D0`…`D15` in high-impedance state (**Z**) if they are not addressed. If a device needs more time than a single bus cycle and is still busy, it can pull `HOLD#` down to signal the **MMU** to wait until `HOLD#` is high again.

#### Word Transfer

bla bla

#### Byte Transfer

bla bla

#### Bus Delay

bla bla

### Devices

Devices are attached to the **BUS** and provide either I/O facilities or memory banks. Each device is selected by the upper 8 bit of the bus address. Thus, up to 256 devices may be addressed in the system.
