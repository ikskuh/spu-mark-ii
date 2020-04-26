# The SPU Assembly Language

## Introduction

The highly flexible nature of the instruction set of the *SPU Mark II* makes it
different to put all possible instructions into useful mnemonics. So the assembly
language allows the coder to put modifiers on each instruction. These modifiers
allow to change any field of the instruction they are put on.

```asm
; fn(str: [*:0]const u8) void
; prints a string to the serial terminal
serial_puts:
	bpget
	spget
	bpset
	
	get 2 ; arg 1
puts_loop:
	ld8 [i0:peek] [f:yes]
	[ex:nonzero] st8 0x4000
	[ex:nonzero] add 1
	[ex:nonzero] jmp puts_loop
	pop

	bpget
	spset
	bpset
	ret
```

## General Syntax

The assembley language is, as most assembly languages, line based. Lines can contain the following:

- Nothing
- A directive (`.equ`)
- A label (`name:`)
- A mnemonic + (optional) operands (`push 10`)
- A label and a mnemonic (`start: push 2`)

Lines may also contain a comment, which is introduced by `;`. Everything from the start of the
comment till the end of the line is ignored by the assembler.

The assembler has a *memory stream* and most operations will insert data into this memory stream.
The memory stream starts at address `0x0000` and the write address can be changed by using `.org`.

### Mnemonics

A mnemonic is a short, easily memorable sequence of letters and digits like `cmp` (read: *compare*) or `st8` (read: *store 8 bit*). Each mnemonic corresponds to a single instruction that will be inserted in the *memory stream*. Mnemonics have have either zero, one or two operands.

### Operands

Some mnemonic requries operands. They are 16 bit values that will be inserted into the *memory stream* after the mnemonic.

Operands follow in the current line after the mnemonic, separated by at least a single space character. If an instruction has two operands, they are comma separated:

```asm
  ; 10 is used as a placeholder value, any value can be used here.
  nop
  push 10
  add 10, 10
```

### Modifiers

Modifiers change certain bit fields in the instruction. They are written between square brackets and have two parts separated by a colon. The first part defines which bit field is modified, the second part defines the new value for this replacement:

```asm
  nop [i1:pop] ; this instruction is similar to the mnemonic `pop`
```

In this example, the `nop` instruction is modified to get its `input1` by popping a value off the stack. `i1` is the identification for `input1`, `pop` is the value for that field.

The following modifiers exist:

#### `i0`
Modifies the `input0` field of the instruction. This values are allowed:

| Value  | Effect                                               |
|--------|------------------------------------------------------|
| `zero` | Changes the *Input 0 Behaviour* field to *zero*      |
| `imm`  | Changes the *Input 0 Behaviour* field to *immediate* |
| `peek` | Changes the *Input 0 Behaviour* field to *peek*      |
| `pop`  | Changes the *Input 0 Behaviour* field to *pop*       |

#### `i1`
Modifies the `input1` field of the instruction. This values are allowed:

| Value  | Effect                                    |
|--------|-------------------------------------------|
| `zero` | Changes the *Input 1 Behaviour* field to *zero*      |
| `imm`  | Changes the *Input 1 Behaviour* field to *immediate* |
| `peek` | Changes the *Input 1 Behaviour* field to *peek*      |
| `pop`  | Changes the *Input 1 Behaviour* field to *pop*       |

#### `ex`
Modifies the `execute` field of the instruction. This values are allowed:

| Value     | Effect                                                |
|-----------|-------------------------------------------------------|
| `always`  | Changes the *Execution Conditional* field to *Always* |
| `zero`    | Changes the *Execution Conditional* field to `=0`     |
| `nonzero` | Changes the *Execution Conditional* field to `≠0`	    |
| `greater` | Changes the *Execution Conditional* field to `>0`     |
| `less`    | Changes the *Execution Conditional* field to `<0`     | 
| `gequal`  | Changes the *Execution Conditional* field to `≥0`	    |
| `lequal`  | Changes the *Execution Conditional* field to `≤0`	    |

#### `out`

#### `f`

#### `cmd`

### Directives

### Values

## Predefined Mnemonics

| Mnemonic | Number Of Operands | Command | Input 0 | Input 1 | Output | Modify Flags | Execution |
|----------|--------------------|---------|---------|---------|--------|--------------|-----------|
|          |                    |         |         |         |        |              |           |

## Predefined Directives

### `.org`

### `.equ`

### `.align`

### `.db`

### `.dw`

### `.ascii`

### `.asciiz`
