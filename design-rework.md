input0, input1 := (0, arg, pop, peek) → 4 bit
execZ, execN   := (X, 0, 1) → 4 bit
flagmod        := (yes, no) → 1 bit
output         := (discard, push, jump, reljump) → 2 bit
command        := (copy, store, load, get, set, bpget, bpset, cpget, math, spget, spset, io, int, sei, cli) → 9 bit

16 Bit:
0 1 2 3 4 5 6 7 8 9 A B C D E F
E E e e I I i i F O O C C C C C

  [0:1] → ExecZ
  [2:3] → ExecN
  [4:5] → Input 0
  [6:7] → Input 1
  [8:8] → Mod Flags
 [9:10] → Output
[11:15] → Command

ExecZ/N:
	00 if not set
	01 if set
	10 always
	11 always

Input0/1:
	00 Zero
	01 Argument
	10 Peek
	11 Pop

Output:
	00 Discard
	01 Push
	10 Jump
	11 Jump Relative

Command:
	00000 COPY
	00001 CPGET
	00010 GET
	00011 SET
	00100 STOR8
	00101 STOR16
	00110 SETINT  (input0 → an/aus)
	00111 INT     (input0 = #intr)
	01000 LOAD8
	01001 LOAD16
	01010 Input  (i0 = port)
	01011 Output (i0 = port, i1 = value)
	01100 BPGET
	01101 BPSET
	01110 SPGET
	01111 SPSET
	10000 ADD
	10001 SUB
	10010 MUL
	10011 DIV
	10100 MOD
	10101 AND
	10110 OR
	10111 XOR
	11000 NOT
	11001 NEG
	11010 ROL
	11011 ROR
	11100 ASL
	11101 ASR
	11110 LSL
	11111 LSR

Execute-Cycle:

- Fetch Instruction
- Increment CP
- Check Execution
	- yes: continue
	- no: next
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


while(true)
{
	// CYC 0
	(execZ, execN, i0, i0, fmod, resop, cmd) = RAM[CP];
	CP++;
	
	// CYC 1
	if (((execZ != 'X') && (execZ != flags.z)) &&
	    ((execN != 'X') && (execN != flags.n)))
	{
		if(i0) CP++;
		if(i1) CP++;
		continue;
	}
	
	input0 = readInput(i0);
	
	// CYC 2
	input1 = readInput(i1);
	output = 0;
	
	// CYC 3
	switch(cmd)
	{
		case COPY:
			output = input0;
			break;
		case ...
	}
	
	// CYC 4
	if(fmod) {
		flags.z = (output == 0);
		flags.n = (output < 0);
	}
	switch(resop)
	{
		case disc: break;
		case push: push(result); break;
		case jmp: cp = result & 0xFFFE; break;
		case rjmp: cp = (cp + result) & 0xFFFE; break;
	}
}