rem Put here the path where your nasm assembler is
set path=E:\Prog_Swan\nasm

set prog=Loader

nasm -f bin -o %prog%.wsc %prog%.asm

pause
