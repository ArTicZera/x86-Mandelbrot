nasm -fbin mandel.asm -o mandel.bin
qemu-system-i386 -drive format=raw,file="mandel.bin"