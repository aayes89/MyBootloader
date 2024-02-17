# MyBootloader
First attempt to make an Bootloader with Nasm

Although the theme appears to be a classic hacker environment, don't be confused, there is nothing dangerous in the code, I just experiment with graphical modes and managing CPU cycles to create timers.

Was tested on MacOS and GNU/Linux.

# DONE
* Bootloader with some ASCII art
* Functional menu (at least the last two options)

# TODO
* Determine what to do with the first menu options

# HOW TO USE
* install Nasm, QEmu and run:
  <code>
  nasm boot.asm -f bin -o boot.bin
  qemu-system-x86_64 boot.bin
  </code>

