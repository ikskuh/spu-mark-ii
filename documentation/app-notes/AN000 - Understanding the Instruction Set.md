## Instructions

Each instruction is composed of a set of bit fields defining the behaviour:
- Command
- Execution
- Input 0
- Input 1
- Output
- Flag Modifier

The most relevant field is the *command* part. It defines what the CPU actually does
with your data. There are 32 commands from which are some still reserved. They provide
the ability to modify data (ALU), modify memory (load/store) or modify aux registers.

Each *command* has two input values: *input 0* and *input 1*. These get fetched by the
cpu and get passed two the *command*. It will then process both values and will yield
an *output*. The cpu will then dispatch the output value as specified in the instruction.

An *output* can be discarded, pushed to the stack or used as a jump target. This means
that actually *all instructions can be jump instructions*! Discarding an output might
sound unnecessary, but it has its uses as well:

To remove a value from the stack, the *command* `COPY` is used and the output is just
discarded. This means that we can fetch values from the stack and don't push new ones.
We successfully implemented `pop` by assembling an instruction.

Each instruction has also a bit that, when set, will update the flags of the cpu
according to the *output* of the command. There are two flags relevant for the
normal program control flow: *zero* and *negative*. These flags will only be changed
when an instruction has the *modify flags* bit set. Then, the *zero* flag will be set
when *output* is zero and the *negative* flag will be set when the highest significant
bit in *output* is set (and thus is negative in two's complement).

The flags can then be used to execute instructions conditionally. The *execution* field
of an instruction defines for which combination of flags the instruction is actually
executed. This is similar to other architectures like ARM or the Parallax Propeller that
allow instructions to be executed conditionally instead of having a dedicated *conditional jump*,
*conditional move* or similar. It is also different from instructions like the AVR *skip*
which requires an additional fetch cycle.

Conditional execution checks for different combinations of flags that are semantically
relevant. This yields 7 conditions: always, less-or-equal, greater-or-equal, less-than,
greater-than, non-equal (or non-zero) and equal (or zero).

Now only two fields are unexplained: *input 0* and *input 1*. Both fields have the same
semantics and the same options: *zero*, *immediate*, *peek* and *pop*.

*Zero* is the simplest one and means that the input field gets set to 0. *Immediate* means
that value for that field is encoded in the instruction itself and is not dependent on 
runtime properties. This is usually used for addresses, offsets, magic numbers or similar.
*Peek* and *pop* both take the value of the stack top, and *pop* will remove the value
from the stack whereas *peek* will keep the stack pointer itself untouched.

## Registers

> TODO: Explain what the four core registers do

## Common Patterns

> TODO: Explain how some coding patters are and how
> to write basic code for the processor.

```asm
; Check an an 8 bit value
sgxt [f:yes] [out:discard]
```