# Gponline
This is an assembly code for Apple II with ProDOS.

It illustrates a technique given by peter ferrie to get the prefix when it's empty.
It uses online mli call, using the last slotd/rive stored in :
devnum      equ $BF30   ; last used device DSSS0000 !!!
