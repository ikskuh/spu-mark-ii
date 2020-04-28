## Call Site

The caller of a function follows this procedure:

1. If function has a return value, push placeholder for the return value
2. Push arguments back-to-front on the stack
3. Push return address on the stack
4. Jump to the target function
5. Pop all arguments from stack
6. Process return value if any

For a function without args and return value, the simplest call looks like this:
```asm
  ipget 2   ; Position-independent getter for return address 
  jmp func  ; Jump to function
```

For a function with the C signature `int16_t sum(int16_t a, int16_t b)` the code
looks like this:
```asm
  push 0   ; return value
  push b   ; arg 2
  push a   ; arg 1
  ipget 2  ; return address
  jmp func ; execute call
  pop      ; remove arg 1
  pop      ; remove arg 2
  ; here the return value is on top of the stack and can be processed further 
```

## Function Site

Functions called with the Standard Calling Convention need to modify the
Base Pointer in order to access both function arguments as well as the return
type. before modifying the Base Pointer, the old Base Pointer must be saved:

```asm
func:
  bpget ; save caller base pointer on the stack
  spget ; \
  bpset ; + Set new base pointer to current stack stop

  …     ; Function implement goes here

  bpget ; \
  spset ; + Restore previous stack frame
  bpset ; Restore caller base pointer
  ret   ; Return to caller
```

Inside the function, arguments, return value, return address and previous Base Pointer
can be accessed by using `get` and `set`. The offsets for this are:

| Offset   | Value               |
|----------|---------------------|
| 0        | caller Base Pointer |
| 1        | return address      |
| 2+*c*    | Argument *c*        |
| 2+*argc* | return value        |

Passing negative values to `get` or `set` will return values local to the function stack
and thus allow simple access to local variables.

A function implementing this C code:

```c
int16_t sum(int16_t a, int16_t b)
{
  return a + b;
}
```

looks like this:

```asm
func:
  bpget ; save caller base pointer on the stack
  spget ; \
  bpset ; + Set new base pointer to current stack stop

  get 2
  get 3
  add
  set 4

  bpget ; \
  spset ; + Restore previous stack frame
  bpset ; Restore caller base pointer
  ret   ; Return to caller
```
