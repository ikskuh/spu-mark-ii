<meta charset="UTF-8" />
<style type="text/css">
table, td, th {
	padding: 0.25em;
	border: 1px solid black;
	border-collapse: collapse;
}
</style>
# SPU Mark II - Memory Management Unit

- 16 bit virtual addresses
- 24 bit physical addresses
- 256 MMU / interrupt contexts (cpu state + mmu config)
- 16 banks a 4096 byte -> 64 kB address space
- Provides interrupt handling

Context:

- 64 bit CPU state (all cpu registers)
	- IP, BP, SP, Flags
- 16 * 16 bit per page (12 bit physical address + 4 flag bits)
	- 64 byte size with padding

## MMU Context

> TODO: Are contexts memory mapped or location freely configurable by CPU instruction?
> + Memory mapped is better for flexibility, does not require instructions
> - When mmu contexts are unmapped in all contexts, the system cannot access them anymore

A MMU context is the current set up of the MMUs banking config as well
as a backup storage for current register set.

| Field Offset | Field Size | Description      |
|--------------|------------|------------------|
| `00`₁₆       | `02`₁₆     | Context Flags    |
| `02`₁₆       | `02`₁₆     | **IP** Backup    |
| `04`₁₆       | `02`₁₆     | **BP** Backup    |
| `06`₁₆       | `02`₁₆     | **SP** Backup    |
| `08`₁₆       | `02`₁₆     | **Flags** Backup |
| …            | `18`₁₆     | reserved (must be zero) |
| `20`₁₆       | `02`₁₆     | bank[0] config   |
| `22`₁₆       | `02`₁₆     | bank[1] config   |
| `24`₁₆       | `02`₁₆     | bank[2] config   |
| `26`₁₆       | `02`₁₆     | bank[3] config   |
| `28`₁₆       | `02`₁₆     | bank[4] config   |
| `2A`₁₆       | `02`₁₆     | bank[5] config   |
| `2C`₁₆       | `02`₁₆     | bank[6] config   |
| `2E`₁₆       | `02`₁₆     | bank[7] config   |
| `30`₁₆       | `02`₁₆     | bank[8] config   |
| `32`₁₆       | `02`₁₆     | bank[9] config   |
| `34`₁₆       | `02`₁₆     | bank[10] config  |
| `36`₁₆       | `02`₁₆     | bank[11] config  |
| `38`₁₆       | `02`₁₆     | bank[12] config  |
| `3A`₁₆       | `02`₁₆     | bank[13] config  |
| `3C`₁₆       | `02`₁₆     | bank[14] config  |
| `3E`₁₆       | `02`₁₆     | bank[15] config  |

### Register backups
Flat copy of the register value, no adjustments.

### Bank configs

| Bitfield Location | Description |
|-------------------|--------------|
| `[0:0]`           | Bank enabled|
| `[1:1]`           | Bank write-protect (`0`=read-only, `1`=read-write) |
| `[3:2]`           | reserved, must be zero |
| `[15:4]`          | Physical bank address base `[23:10]`|

## Context Config
The MMU holds an array of 256 contexts addresses, each 24 bit wide.
Each address contains a physical pointer to its corresponding MMU context.

## Interrupt Config

> TODO: Are interrupt configurations memory mapped or freely configurable by CPU instruction?
> + Memory mapped is better for flexibility, does not require instructions
> + Interrupt configuration may be broken, but cpu will still work!

## MMU Commands

- SwitchContext
	- Backs up current context, restores new context (`input0`), passthrough of `input1` to output (allows jumping into a context)
- ConfigContext
  - Sets the context pointer `input1[15:8]` to `concat(input1[7:0], input0[15:0])`
- ConfigInterrupt
  - `input0` is interrupt config bitfield, `input1` is interrupt number
- ConfigGlobalInterrupts
  - `input0` contains interrupt config

## Context Switches

When a context switch is initiated, the following steps happen:
1. The current CPU state will be written into the current context
2. The current context is set to the context which is beeing switched to
3. The page configurations are loaded from memory
4. The CPU state will be restored to the one located in the current context
5. Execution continues
	
## Initialization

The MMU will start with the context *0* enabled and all bank configurations are initialized with *bank enabled*,
*bank read-write* and the base address of the banks is set to a linear offset (`0000`₁₆ to `F000`₁₆).

This allows the system to be used without the use of the MMU.