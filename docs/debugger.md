# Debugger

- Run
- Break
- Single-Step
- Load IHEX
- Load Word(s)
- Load Byte(s)
- Store Word
- Store Byte
- Breakpoints (Addr)
- Trace current instr + effects
- "GoTo" / Jump
- Push
- Pop
- Show CPU State + Stack

"r"           → run
"^C"          → break
"s"           → step
"L"           → load IHEX
"p ????"      → Print word at ????
"s ???? !!"   → store byte !! to ????
"s ???? !!!!" → store word !!!! to ????
"b ????"      → toggle breakpoint at ????
"T"           → toggle tracee
"J ????"      → jump to ????
"+ ????"      → push ????
"-"           → pop
"?"           → print CPU state + stack