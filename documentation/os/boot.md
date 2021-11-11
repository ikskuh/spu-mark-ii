# Boot Process

## Brain Dump

1. `<no process>` Initialize default memory map
2. `<no process>` Initialize and detect HW
3. `<no process>` Create process "init"
4. `<no process>` Jump into "init" process
5. `<init>` Check HDDs for an OS signature
6. `<init>` Display boot menu
7. `<init>` If nothing selected, create process with "ROM BASIC"
8. `<rom basic>` does its thing