# SPU Mark II - Architecture

## Overview

- RISC
- Stack Based
- 16 Bit
- MMU
- Memory Mapped I/O only

## Purpose Of This Document

## Table Of Contents

## Registers

### Stack Pointer

### Base Pointer

### Instruction ~~Code~~ Pointer
Entry Point: 0x0000

## Instruction Encoding

16 Bit:
0 1 2 3 4 5 6 7 8 9 A B C D E F
E E E F I I i i O O C C C C C C

  [0:2] → Exec
	[3:3] → Mod Flags
  [4:5] → Input 0
  [6:7] → Input 1
  [8:9] → Output
[10:15] → Command

### Argument Input

Input0/1:
	00 Zero
	01 Argument
	10 Peek
	11 Pop

### Result Output

Output:
	00 Discard
	01 Push
	10 Jump
	11 Jump Relative

### Flag Modification

Modify:
	0 no
	1 yes

### Conditional Execution

Exec:
	000 always
	001 =0
	010 ≠0
	011 >0
	100 <0
	101 ≥0
	110 ≤0
	111 never

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
	001010 MAPMMU (input0 = bank, input1 = value)
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
- Increment CP
- Check Execution
	- yes: continue
	- no: next, increment CP for i0, i1
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
	- rjmp: jump to CP+result

## Memory Access

- 16 pages with 4 kB
- Each page has access bits
- Each page can map to an arbitrary 12 bit aligned address

## Task Switching

- 256 Tasks
- Switch Tasks

## Interrupts

## I/O