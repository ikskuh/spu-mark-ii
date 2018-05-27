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
| `[4:3]`   | Input 0 Behaviour                  |
| `[6:5]`   | Input 1 Behaviour                  |
| `[7:7]`   | Flag Modification Behaviour        |
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

| Value    | Name    | Short Description
|----------|---------|------------------------|
| `000000` | COPY    | Copies input0 to output.
| `000001` | IPGET   | Gets the instruction pointer to the next instruction
| `000010` | GET     | Gets a value from the tack. (input0 = index relative to BP, 0 is stacktop)
| `000011` | SET     | Sets a value on the stack (input0 = index relative to BP, 0 is stacktop)
| `000100` | STORE8  | Stores a byte in memory 
| `000101` | STORE16 | Stores a word in memory
| `000110` | LOAD8   | Loads a byte from memory
| `000111` | LOAD16  | Loads a word from memory
| `001000` | ???     |
| `001001` | ???     |
| `001010` | ???     |
| `001011` | ???     |
| `001100` | BPGET   | Gets the base pointer
| `001101` | BPSET   | Sets the base pointer
| `001110` | SPGET   | Gets the stack pointer
| `001111` | SPSET   | Sets the stack pointer
| `010000` | ADD     | `input0 + input1`
| `010001` | SUB     | `input0 - input1`
| `010010` | MUL     | `input0 * input1`
| `010011` | DIV     | `input0 / input1`
| `010100` | MOD     | `input0 % input1`
| `010101` | AND     | `input0 & input1`
| `010110` | OR      | `input0 | input1`
| `010111` | XOR     | `input0 ^ input1`
| `011000` | NOT     | `~input0`
| `011001` | NEG     | `-input0`
| `011010` | ROL     | rotates input0 to the left
| `011011` | ROR     | rotates input0 to the right
| `011100` | BSWAP   | swaps the bytes of input0 (output=byteSwap(input0))
| `011101` | ASR     | arithmetic shift right of input0
| `011110` | LSL     | logical shift left of input0
| `011111` | LSR     | logical shift right of input0
| `1*****` | ???     | *yet to determine what to do with this bit*

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
