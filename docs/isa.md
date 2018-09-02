<meta charset="UTF-8" />
<style type="text/css">
table, td, th {
	padding: 0.25em;
	border: 1px solid black;
	border-collapse: collapse;
}
</style>
# SPU Mark II - Architecture

## Overview

- RISC (?)
- Stack Based
- 16 Bit Data
- No special I/O commands

## Purpose Of This Document

## Table Of Contents

## Registers

### Stack Pointer
16 bit register pointing to the stack top

| Bit Fields | Description               |
|------------|---------------------------|
| `[0:0]`    | reserved, must be zero    |
| `[15:1]`   | aligned stack top address |

Initial Value: *Undefined*

### Base Pointer
16 bit register pointing to the current stack frame.

| Bit Fields | Description                 |
|------------|-----------------------------|
| `[0:0]`    | reserved, must be zero      |
| `[15:1]`   | aligned stack frame address |

Initial Value: *Undefined*

### Instruction ~~Code~~ Pointer
16 bit register pointing to the instruction to be executed next.

| Bit Fields | Description                 |
|------------|-----------------------------|
| `[0:0]`    | reserved, must be zero      |
| `[15:1]`   | aligned stack frame address |

Initial Value: `0000`₁₆

### Flags
3 bit register saving non-word CPU state

| Bit Range | Name  | Description        |
|-----------|-------|--------------------|
| `[0:0]`   | **Z** | Zero Flag          |
| `[1:1]`   | **N** | Negative Flag      |
| `[2:2]`   | **I** | Interrupts Enabled |

Initial Value: `0`₁₆

## Instruction Encoding

Instructions use 16 bit opcodes organized in different bit fields defining the
behaviour of the instruction.

| Bit Range | Description                           |
|-----------|---------------------------------------|
| `[2:0]`   | Execution Conditional                 |
| `[4:3]`   | Input 0 Behaviour                     |
| `[6:5]`   | Input 1 Behaviour                     |
| `[7:7]`   | Flag Modification Behaviour           |
| `[9:8]`   | Output Behaviour                      |
| `[14:10]` | Command                               |
| `[15:15]` | Reserved for future use (must be `0`) |

### Conditional Execution

This field determines when the command is executed or ignored. The execution is dependent on the
current state of the flags.

This allows conditional execution of all possible opcodes.

| Value       | Enumeration | Description                                                              |
|-------------|-------------|--------------------------------------------------------------------------|
| `000` (0₁₀) | Always      | The command is always executed                                           |
| `001` (1₁₀) | =0          | The command is executed when result is zero (`Z=1`)                      |
| `010` (2₁₀) | ≠0          | The command is executed when result is not zero (`Z=0`)                  |
| `011` (3₁₀) | >0          | The command is executed when result is positive (`Z=0` and `N=0`)        |
| `100` (4₁₀) | <0          | The command is executed when result is less than zero (`N=1`)            |
| `101` (5₁₀) | ≥0          | The command is executed when result is zero or positive (`Z=1` or `N=0`) |
| `110` (6₁₀) | ≤0          | The command is executed when result is zero or negative (`Z=1` or `N=1`) |
| `111` (7₁₀) | Never       | The command is never executed                                            |

### Argument Input 0 and 1

These two fields define what arguments are provided to the executed command.

| Value       | Enumeration | Description                                              |
|-------------|-------------|----------------------------------------------------------|
| `00`₂ (0₁₀) | Zero        | The input register will be zero.                         |
| `01`₂ (1₁₀) | Immediate   | The input registers value is located after this command. |
| `10`₂ (2₁₀) | Peek        | The input register will be the stack top.                |
| `11`₂ (3₁₀) | Pop         | The input register will be popped from the stack.        |

*Zero* means that the argument will be zeroize, *Immediate* means that it will be fetched
from the instruction pointer (it is located behind the opcode in memory).
*Peek* will take the argument from the stack top, but won't change the stack and *Pop* will
take the argument from the stack top and decreases the stack pointer.

`input0` is fetched before `input1` so when both arguments pop a value, `input0` receives the
stack top and `input1` receives the value one below the stack top. Likewise, when both arguments
use the *Immediate* option, the value for `input0` must located directly after the opcode, `input1`
directly after `input0`.

### Flag Modification

When the flag modification is enabled, the current flags will be overwritten by this command.
Otherwise the flags stay as they were before the instruction.

| Value      | Enumeration | Description                                            |
|------------|-------------|--------------------------------------------------------|
| `0`₂ (0₁₀) | No          | The flags won't be modified.                           |
| `1`₂ (1₁₀) | Yes         | The flags will be set according to the command output. |

The flags are modified according to this table:

| Flag  | Condition          |
|-------|--------------------|
| **Z** | `output[15:0] = 0` |
| **N** | `output[15] = 1`   |
| **I** | unchanged          |

### Result Output

Each command may output a value which can be processed in various ways. The output could
be pushed to the stack, the command could be made into a jump or the output could be ignored.

| Value       | Enumeration   | Description                                                  |
|-------------|---------------|--------------------------------------------------------------|
| `00`₂ (0₁₀) | Discard       | The command output will be ignored.                          |
| `01`₂ (1₁₀) | Push          | The command output will be pushed to the stack.              |
| `10`₂ (2₁₀) | Jump          | The instruction pointer will be set to the command output.   |
| `11`₂ (3₁₀) | Jump Relative | The command output will be added to the instruction pointer. |

### Commands

Commands are what define the core behaviour of the opcode. They allow arithmetics, modification of memory,
changing system registers and so on.

| Value           | Name    | Short Description                                                | Pseudo-Code
|-----------------|---------|------------------------------------------------------------------|-------------
| `00000`₂  (0₁₀) | COPY    | Copies `input0` to `output`.                                     | `output = input0`
| `00001`₂  (1₁₀) | IPGET   | Gets a pointer to the next instruction after the current opcode. | `output = IP + 2 * input0`
| `00010`₂  (2₁₀) | GET     | Gets a value from the stack.                                     | `output = MEM16[BP + 2 * input0]`
| `00011`₂  (3₁₀) | SET     | Sets a value on the stack                                        | `output = input1; MEM16[BP + 2 * input0] = input1`
| `00100`₂  (4₁₀) | STORE8  | Stores a byte in memory                                          | `output = input1; MEM8[input0] = input1`
| `00101`₂  (5₁₀) | STORE16 | Stores a word in memory                                          | `output = input1; MEM16[input0] = input1`
| `00110`₂  (6₁₀) | LOAD8   | Loads a byte from memory                                         | `output = MEM8[input0]`
| `00111`₂  (7₁₀) | LOAD16  | Loads a word from memory                                         | `output = MEM8[input0]`
| `01000`₂  (8₁₀) | ???     |                                                                  |
| `01001`₂  (9₁₀) | ???     |                                                                  |
| `01010`₂ (10₁₀) | ???     |                                                                  |
| `01011`₂ (11₁₀) | ???     |                                                                  |
| `01100`₂ (12₁₀) | BPGET   | Gets the base pointer                                            | `output = BP`
| `01101`₂ (13₁₀) | BPSET   | Sets the base pointer                                            | `output = BP = input0`
| `01110`₂ (14₁₀) | SPGET   | Gets the stack pointer                                           | `output = SP`
| `01111`₂ (15₁₀) | SPSET   | Sets the stack pointer                                           | `output = SP = input0`
| `10000`₂ (16₁₀) | ADD     | Adds the two inputs                                              | `output = input0 + input1`
| `10001`₂ (17₁₀) | SUB     | Subtracts `input1` from `input0`                                 | `output = input0 - input1`
| `10010`₂ (18₁₀) | MUL     | Multiplies `input0` and `input1`                                 | `output = input0 * input1`
| `10011`₂ (19₁₀) | DIV     | Divides `input0` by `input1`                                     | `output = input0 / input1`
| `10100`₂ (20₁₀) | MOD     | Divides `input0` by `input1` and returns the remainder.          | `output = input0 % input1`
| `10101`₂ (21₁₀) | AND     | Combines the bits in `input0` and `input1` with AND              | `output = input0 & input1`
| `10110`₂ (22₁₀) | OR      | Combines the bits in `input0` and `input1` with inclusive OR     | `output = input0 | input1`
| `10111`₂ (23₁₀) | XOR     | Combines the bits in `input0` and `input1` with exclusive OR     | `output = input0 ^ input1`
| `11000`₂ (24₁₀) | NOT     | Inverts all bits in `input0`                                     | `output = ~input0`
| `11001`₂ (25₁₀) | NEG     | Returns the negative of `input0`.                                | `output = -input0`
| `11010`₂ (26₁₀) | ROL     | Rotates `input0` to the left                                     | `output = concat(input0[14:0], input0[15])`
| `11011`₂ (27₁₀) | ROR     | Rotates `input0` to the right                                    | `output = concat(input0[0], input0[15:1])`
| `11100`₂ (28₁₀) | BSWAP   | Swaps the bytes of `input0`                                      | `output = concat(input0[7:0], input0[15:8])`
| `11101`₂ (29₁₀) | ASR     | Arithmetic shift right of `input0`                               | `output = concat(input0[15], input0[15:1])`
| `11110`₂ (30₁₀) | LSL     | Logical shift left of `input0`                                   | `output = concat(input0[14:0], '0')`
| `11111`₂ (31₁₀) | LSR     | Logical shift right of `input0`                                  | `output = concat('0', input0[15:1])`

## Memory Access

Only 2-aligned access to memory is possible with code or data.
Only exception are the `STORE8` and `LOADE8` commands which allow unaligned memory access.

When accessing memory with alignment, the least significant address bit is reserved and must be `0`.

## Fetch-Execute-Cycle

```
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
```
