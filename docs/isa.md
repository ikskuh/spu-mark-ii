# SPU Mark II - Architecture

## Overview

- RISC
- Stack Based
- 16 Bit Data
- No special I/O commands

## Purpose Of This Document

## Table Of Contents

## Registers

### Stack Pointer
16 bit register pointing to the stack top

### Base Pointer
16 bit register pointing to the current stack frame.

### Instruction ~~Code~~ Pointer
16 bit register pointing to the instruction to be executed next.

Entry Point: 0x0000

### Flags
3 bit register saving non-word CPU state

| Bit Range | Name  | Description        |
|-----------|-------|--------------------|
| `[0:0]`   | **Z** | Zero Flag          |
| `[1:1]`   | **N** | Negative Flag      |
| `[2:2]`   | **I** | Interrupts Enabled |

## Instruction Encoding

The instructions are coded in different sections, each describing a part of the instructions
behaviour. 

| Bit Range | Description                        |
|-----------|------------------------------------|
| `[2:0]`   | Execution Conditional              |
| `[3:3]`   | Flag Modification Behaviour        |
| `[5:4]`   | Input 0 Behaviour                  |
| `[7:6]`   | Input 1 Behaviour                  |
| `[9:8]`   | Output Behaviour                   |
| `[15:10]` | Command                            |

### Conditional Execution

| Value | Enumeration | Description                                                              |
|-------|-------------|--------------------------------------------------------------------------|
| `000` | Always      | The command is always executed                                           |
| `001` | =0          | The command is executed when result is zero (`Z=1`)                      |
| `010` | ≠0          | The command is executed when result is not zero (`Z=0`)                  |
| `011` | >0          | The command is executed when result is positive (`Z=0` and `N=0`)        |
| `100` | <0          | The command is executed when result is less than zero (`N=1`)            |
| `101` | ≥0          | The command is executed when result is zero or positive (`Z=1` or `N=0`) |
| `110` | ≤0          | The command is executed when result is zero or negative (`Z=1` or `N=1`) |
| `111` | Always      | The command is never executed                                            |

This field determines when the command is executed or ignored. The execution is dependent on the
current state of the flags.

This allows conditional execution of all possible opcodes.

### Flag Modification

| Value  | Enumeration | Description                                            |
|--------|-------------|--------------------------------------------------------|
| `0`    | No          | The flags won't be modified.                           |
| `1`    | Yes         | The flags will be set according to the command output. |

When the flag modification is enabled, the current flags will be overwritten by this command.
Otherwise the flags stay as they were before the instruction.

The flags are modified according to this table:

| Flag  | Condition          |
|-------|--------------------|
| **Z** | `output[15:0] = 0` |
| **N** | `output[15] = 1`   |
| **I** | unchanged          |

### Argument Input 0 and 1

| Value | Enumeration | Description                                              |
|-------|-------------|----------------------------------------------------------|
| `00`  | Zero        | The input register will be zero.                         |
| `01`  | Argument    | The input registers value is located after this command. |
| `10`  | Peek        | The input register will be the stack top.                |
| `11`  | Pop         | The input register will be popped from the stack.        |

When fetching command arguments, the bits `[5:4]` and `[7:6]` determine what value this
argument has.
*Zero* means that the argument will be zeroize, *Argument* means that it will be fetched
from the instruction pointer (it is located behind the opcode in memory).
*Peek* will take the argument from the stack top, but won't change the stack and *Pop* will
take the argument from the stack top and decreases the stack pointer.

### Result Output

| Value | Enumeration   | Description                                                  |
|-------|---------------|--------------------------------------------------------------|
| `00`  | Discard       | The command output will be ignored.                          |
| `01`  | Push          | The command output will be pushed to the stack.              |
| `10`  | Jump          | The instruction pointer will be set to the command output.   |
| `11`  | Jump Relative | The command output will be added to the instruction pointer. |

Each command may output a value which can be processed in various ways. The output could
be pushed to the stack, the command could be made into a jump or the output could be ignored.

### Commands
Command:
	000000 COPY
	000001 CPGET
	000010 GET (input0 = index relative to BP, 0 is stacktop)
	000011 SET (input0 = index relative to BP, 0 is stacktop)
	000100 STOR8
	000101 STOR16
	000110 SETINT  (input0 → an/aus)
	000111 INT     (input0 = #intr)
	001000 LOAD8
	001001 LOAD16
	001010 ???
	001011 ???
	001100 BPGET
	001101 BPSET
	001110 SPGET
	001111 SPSET
	010000 ADD
	010001 SUB
	010010 MUL
	010011 DIV
	010100 MOD
	010101 AND
	010110 OR
	010111 XOR
	011000 NOT
	011001 NEG
	011010 ROL
	011011 ROR
	011100 BSWAP (output=byteSwap(input0))
	011101 ASR
	011110 LSL
	011111 LSR
	1***** ???

## Fetch-Execute-Cycle

Execute-Cycle:
- Fetch Instruction
- Increment IP
- Check Execution
	- yes: continue
	- no: next, increment IP for i0, i1
- Gather Input 0
- Gather Input 1
- Execute CMD
- Check flags:
	- yes: Writeback Flags
	- no: leave unchanged
- Check result:
	- push: push result
	- discard: nothing
	- jmp: jump to result
	- rjmp: jump to IP+result

## Memory Access

Only 2-aligned access to memory is possible with code or data.
Only exception are the `STOR8` and `LOAD8` commands which allow unaligned memory access.

When accessing memory with alignment, the least significant address bit is ignored, so the 
address `0x0001` will be interpreted as `0x0000`.

## Interrupts
