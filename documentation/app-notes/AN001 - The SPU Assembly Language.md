## Example

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

### Labels

Labels name a location in the *memory stream*. When a label is encountered, the assembler will create a symbol with the labels name and its position. You can forward-reference labels. This means you can use a label before it was created in the code.

```asm
named_position: ; this is the label
	nop           ; and has the address of this instruction

label_a: 
label_b: ; has the same address as label_a
```

The rules for valid label names is quite easy: All latin letters (`A`…`Z`, `a`…`z`), underscore (`_`) and digits (`0`…`9`). The only restriction is that a label name *must not* start with a digit.

Label names may also start with a `.`, following the same rules as directives. A label named this way must not have the same name as a directive. These labels are called *local* and are only valid between two normal labels:

```asm
my_function_a: ; global label
	…
.loop:         ; local label
	jmp .loop
	…

my_function_b: ; global label, .loop does not exist anymore at this position.
```

### Mnemonics

A mnemonic is a short, easily memorable sequence of letters and digits like `cmp` (read: *compare*) or `st8` (read: *store 8 bit*). Each mnemonic corresponds to a single instruction that will be inserted in the *memory stream*. Mnemonics have have either zero, one or two operands.

### Operands

Some mnemonic requries operands. They are 16 bit values that will be inserted into the *memory stream* after the instruction.

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
Modifies the *Input 0 Behaviour* field of the instruction. This values are allowed:

| Value  | Effect                                               |
|--------|------------------------------------------------------|
| `zero` | Changes the *Input 0 Behaviour* field to *zero*      |
| `imm`  | Changes the *Input 0 Behaviour* field to *immediate* |
| `peek` | Changes the *Input 0 Behaviour* field to *peek*      |
| `pop`  | Changes the *Input 0 Behaviour* field to *pop*       |

#### `i1`
Modifies the *Input 1 Behaviour* field of the instruction. This values are allowed:

| Value  | Effect                                               |
|--------|------------------------------------------------------|
| `zero` | Changes the *Input 1 Behaviour* field to *zero*      |
| `imm`  | Changes the *Input 1 Behaviour* field to *immediate* |
| `peek` | Changes the *Input 1 Behaviour* field to *peek*      |
| `pop`  | Changes the *Input 1 Behaviour* field to *pop*       |

#### `ex`
Modifies the *Execution Conditional* field of the instruction. This values are allowed:

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
Modifies the *Output Behaviour* field of the instruction. This values are allowed:

| Value     | Effect                                                  |
|-----------|---------------------------------------------------------|
| `discard` | Changes the *Output Behaviour* field to *Discard*       |
| `push`    | Changes the *Output Behaviour* field to *Push*          |
| `jmp`     | Changes the *Output Behaviour* field to *Jump*          |
| `rjmp`    | Changes the *Output Behaviour* field to *Jump Relative* |

#### `f`
Modifies the *Flag Modification Behaviour* field of the instruction. This values are allowed:

| Value | Effect                                                       |
|-------|--------------------------------------------------------------|
| `no`  | Changes the *Flag Modification Behaviour* field to *Discard* |
| `yes` | Changes the *Flag Modification Behaviour* field to *Push*    |


#### `cmd`
Modifies the *Command* field of the instruction. This values are allowed:

| Value     | Effect                                   |
|-----------|------------------------------------------|
| `copy`    | Changes the *Command* field to `COPY`    |
| `ipget`   | Changes the *Command* field to `IPGET`   |
| `get`     | Changes the *Command* field to `GET`     |
| `set`     | Changes the *Command* field to `SET`     |
| `store8`  | Changes the *Command* field to `STORE8`  |
| `store16` | Changes the *Command* field to `STORE16` |
| `load8`   | Changes the *Command* field to `LOAD8`   |
| `load16`  | Changes the *Command* field to `LOAD16`  |
| `frget`   | Changes the *Command* field to `FRGET`   |
| `frset`   | Changes the *Command* field to `FRSET`   |
| `bpget`   | Changes the *Command* field to `BPGET`   |
| `bpset`   | Changes the *Command* field to `BPSET`   |
| `spget`   | Changes the *Command* field to `SPGET`   |
| `spset`   | Changes the *Command* field to `SPSET`   |
| `add`     | Changes the *Command* field to `ADD`     |
| `sub`     | Changes the *Command* field to `SUB`     |
| `mul`     | Changes the *Command* field to `MUL`     |
| `div`     | Changes the *Command* field to `DIV`     |
| `mod`     | Changes the *Command* field to `MOD`     |
| `and`     | Changes the *Command* field to `AND`     |
| `or`      | Changes the *Command* field to `OR`      |
| `xor`     | Changes the *Command* field to `XOR`     |
| `not`     | Changes the *Command* field to `NOT`     |
| `signext` | Changes the *Command* field to `SIGNEXT` |
| `rol`     | Changes the *Command* field to `ROL`     |
| `ror`     | Changes the *Command* field to `ROR`     |
| `bswap`   | Changes the *Command* field to `BSWAP`   |
| `asr`     | Changes the *Command* field to `ASR`     |
| `lsl`     | Changes the *Command* field to `LSL`     |
| `lsr`     | Changes the *Command* field to `LSR`     |

### Directives

Directives change what the assembler does or emit data instead of instructions. Each directive is started with a `.` and has a short an memorable name.

The overall syntax for directives is the same as for mnemonics: Directives can have operands and there can be only one directive or mnemonic per line.

#### `.org`
This directive changes the current position in the memory stream. It takes a single operand that defines the new start position to write code to.

Note that all symbols used in the expression for `.org` must be known when `.org` is encountered and may not depend on future symbols.

```asm
.org 0x1234
	nop ; instruction will be located at offset 0x1234
```

#### `.equ`
This directive defines a new symbol and takes two operands. The first is the symbol name, the second one is the symbol value:

```asm
.equ ten, 10
	push ten ; will use the value defined in the previous line
```

#### `.align`

This directive forward-aligns the current memory pointer to the operands value. This means that it will move the current memory location forward until the memory address is an integer multiple of the operand.

```asm
.org 0x0001
.align 4
	nop ; will be emitted at address 4
```

#### `.db`

This directive inserts a single byte into the memory stream. The directive takes at least one operands, but takes any number of operands. For each operand, a byte is inserted.

```asm
; A nul-terminated sequence of 4 bytes
magic_sequence:
	.db 0x11, 0x22, 0x33, 0x44
	.db 0x00
```

#### `.dw`

Similar to `.db`, but inserts full 16 bit words into the memory stream. It also takes at least one operand and for each operand, a word is inserted.

```asm
; jump table with the first four memory pages
jump_table:
	.dw 0x0000
	.dw 0x1000
	.dw 0x2000
	.dw 0x3000
```

#### `.ascii`

Inserts a stream of bytes based on the ASCII text encoding into the memory stream. It takes a single string operand:

```asm
; NUL-terminated string to the user name.
user_name:
	.ascii "anonymous"
	.db 0x00
```

#### `.asciiz`

Works the same as `.ascii`, but appends an implicit NUL terminator.

```asm
user_name:
	.asciiz "anonymous"
```

#### `.space`
Inserts a number of NUL bytes into the memory stream. It takes a single operand which defines the number of bytes.

Note that all symbols used in the expression for `.space` must be known when `.space` is encountered and may not depend on future symbols.

```asm
scratch_buffer:
	.space 0x1000 ; 4kB of scratch buffer space
```

#### `.include`

Takes a single string operand that specifies a file name that will be included into the assembly process at this point. This allows to structure programs into several files and create libraries.

**main.asm:**
```asm
main:
	push str
	ipget 2
	jmp puts
	pop

.loop:
	jmp .loop

.include "lib.asm"
```

**lib.asm:**
```asm
puts:
	; not yet implemented
	ret
```

When now assembling **main.asm**, the assembler will effectivly see this:

```asm
main:
	push str
	ipget 2
	jmp puts
	pop

.loop:
	jmp .loop
	
puts:
	; not yet implemented
	ret
```

#### `.incbin`
This directive takes a single string operand that specifies a file name. This file will be copied verbatim into the *memory stream* and allows the programmer to embed resources, precalculated tables and other data into the binary without the need to specify each single byte with `.db`.

```asm
sprite:
.dw 128, 64          ; width, height
.incbin "sprite.raw" ; includes our 8192 bytes of sprite pixels
```

### Values

Values are things that can be passed to operands. The usually have 16 bit size and are of numeric nature.

#### Symbols
Symbols are named values defined by labels or `.equ` and have the value which are defined by those.

```asm
loop:
	jmp loop ; Uses the symbol `loop` to refer to adress of the own instruction
```

#### Current Position
The here position is noted by a single `.` which has the value of the current position in the *memory stream*.

```asm
.org 0x1000
	push . ; pushes 0x1000
	push . ; pushes 0x1004
```

#### Integers

Integers are literal numbers that are written in decimal (`10`), hexadecimal (`0x10`), octal (`0o10`) or binary (`0b10`).

```
.equ two,     0b10
.equ eight,   0o10
.equ ten,     10
.equ sixteen, 0x10
```

#### Characters

Characters are an easy way to insert ASCII characters. A character literal is a single character or an escaped character between two `'`:

```
	push 'H'  ; pushes 0x48
	push '\n' ; pushes 0x0A
```

An escaped character is introduced by a `\`, followed by a substitute:

| Escape Sequence | Value  |
|-----------------|--------|
| `\a`            | `0x07` |
| `\b`            | `0x08` |
| `\e`            | `0x1B` |
| `\n`            | `0x0A` |
| `\r`            | `0x0D` |
| `\t`            | `0x0B` |
| `\\`            | `0x5C` |
| `\'`            | `0x27` |
| `\"`            | `0x22` |

Any character escaped that is not in the table above will be printed literally. So `\!` is equivalent to just `!`.

#### Strings
One exception to the numeric nature is the string value. It is only required for some directives and is not usable for mnemonic operands.

A string is started and terminated by `"`. Non-printable characters are escaped by prefixing the character with `\`.

Escaped characters use the same syntax as the *Character* type.

#### Expressions
Expressions are calculations done with values. You can apply unary and binary operators to values and also call built-in functions. The expressions follow the usual syntax found in most programming languages:

```
.equ sum_of_parts, (10 + 20 * bswap(1 - 3))
```

##### Unary Operators

| Operator | Description               |
|----------|---------------------------|
| `-`      | Two's complement negation |
| `~`      | Bitwise inversion         |

##### Binary Operators

| Operator | Description               |
|----------|---------------------------|
| `+`      | Addition                  |
| `-`      | Subtraction               |
| `*`      | Multiplication            |
| `/`      | Division                  |
| `%`      | Modulus                   |
| `&`      | Bitwise and               |
| `\|`     | Bitwise or                |
| `^`      | Bitwise exlusive or       |
| `<<`     | Logic shift left          |
| `>>`     | Logic shift right         |
| `>>>`    | Arithmetic shift right    |

##### Builtin Functions

| Function   | Description                    |
|------------|--------------------------------|
| `bswap(v)` | Swaps high and low byte of `v` |

## Predefined Mnemonics

| Mnemonic  | Number Of Immediate Operands | Command | Input 0   | Input 1   | Output  | Modify Flags |
|-----------|------------------------------|---------|-----------|-----------|---------|--------------|
| `add`     | 0                            | ADD     | pop       | pop       | push    | 0            |
| `add`     | 1                            | ADD     | pop       | immediate | push    | 0            |
| `and`     | 0                            | AND     | pop       | pop       | push    | 0            |
| `and`     | 1                            | AND     | pop       | immediate | push    | 0            |
| `asl`     | 0                            | LSL     | pop       | zero      | push    | 0            |
| `asr`     | 0                            | ASR     | pop       | zero      | push    | 0            |
| `bpget`   | 0                            | BPGET   | zero      | zero      | push    | 0            |
| `bpset`   | 0                            | BPSET   | pop       | zero      | discard | 0            |
| `bpset`   | 1                            | BPSET   | immediate | zero      | discard | 0            |
| `bswap`   | 0                            | BSWAP   | pop       | zero      | push    | 0            |
| `cmp`     | 0                            | SUB     | pop       | pop       | discard | 1            |
| `cmp`     | 1                            | SUB     | pop       | immediate | discard | 1            |
| `cmpp`    | 1                            | SUB     | peek      | immediate | discard | 1            |
| `div`     | 0                            | DIV     | pop       | pop       | push    | 0            |
| `div`     | 1                            | DIV     | pop       | immediate | push    | 0            |
| `dup`     | 0                            | COPY    | peek      | zero      | push    | 0            |
| `get`     | 1                            | GET     | immediate | zero      | push    | 0            |
| `geti`    | 0                            | GET     | pop       | zero      | push    | 0            |
| `ipget`   | 0                            | IPGET   | zero      | zero      | push    | 0            |
| `ipget`   | 1                            | IPGET   | immediate | zero      | push    | 0            |
| `jmp`     | 1                            | COPY    | immediate | zero      | jump    | 0            |
| `jmpi`    | 0                            | COPY    | pop       | zero      | jump    | 0            |
| `ld`      | 0                            | LOAD16  | pop       | zero      | push    | 0            |
| `ld`      | 1                            | LOAD16  | immediate | zero      | push    | 0            |
| `ld8`     | 0                            | LOAD8   | pop       | zero      | push    | 0            |
| `ld8`     | 1                            | LOAD8   | immediate | zero      | push    | 0            |
| `lsl`     | 0                            | LSL     | pop       | zero      | push    | 0            |
| `lsr`     | 0                            | LSR     | pop       | zero      | push    | 0            |
| `mod`     | 0                            | MOD     | pop       | pop       | push    | 0            |
| `mod`     | 1                            | MOD     | pop       | immediate | push    | 0            |
| `mul`     | 0                            | MUL     | pop       | pop       | push    | 0            |
| `mul`     | 1                            | MUL     | pop       | immediate | push    | 0            |
| `neg`     | 0                            | SUB     | zero      | pop       | push    | 0            |
| `nop`     | 0                            | COPY    | zero      | zero      | discard | 0            |
| `not`     | 0                            | NOT     | pop       | zero      | push    | 0            |
| `or`      | 0                            | OR      | pop       | pop       | push    | 0            |
| `or`      | 1                            | OR      | pop       | immediate | push    | 0            |
| `pop`     | 0                            | COPY    | pop       | zero      | discard | 0            |
| `push`    | 1                            | COPY    | immediate | zero      | push    | 0            |
| `replace` | 1                            | COPY    | immediate | pop       | push    | 0            |
| `ret`     | 0                            | COPY    | pop       | zero      | jump    | 0            |
| `rjmp`    | 1                            | COPY    | immediate | zero      | rjmp    | 0            |
| `rol`     | 0                            | ROL     | pop       | zero      | push    | 0            |
| `ror`     | 0                            | ROR     | pop       | zero      | push    | 0            |
| `set`     | 1                            | SET     | immediate | pop       | discard | 0            |
| `seti`    | 0                            | SET     | pop       | pop       | discard | 0            |
| `spget`   | 0                            | SPGET   | zero      | zero      | push    | 0            |
| `spset`   | 0                            | SPSET   | pop       | zero      | discard | 0            |
| `spset`   | 1                            | SPSET   | immediate | zero      | discard | 0            |
| `sgxt`    | 0                            | SIGNEXT | pop       | zero      | push    | 0            |
| `st`      | 0                            | STORE16 | pop       | pop       | discard | 0            |
| `st`      | 1                            | STORE16 | immediate | pop       | discard | 0            |
| `st`      | 2                            | STORE16 | immediate | immediate | discard | 0            |
| `st8`     | 0                            | STORE8  | pop       | pop       | discard | 0            |
| `st8`     | 1                            | STORE8  | immediate | pop       | discard | 0            |
| `st8`     | 2                            | STORE8  | immediate | immediate | discard | 0            |
| `sub`     | 0                            | SUB     | pop       | pop       | push    | 0            |
| `sub`     | 1                            | SUB     | pop       | immediate | push    | 0            |
| `xor`     | 0                            | XOR     | pop       | pop       | push    | 0            |
| `xor`     | 1                            | XOR     | pop       | immediate | push    | 0            |
