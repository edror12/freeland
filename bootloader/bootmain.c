// Boot loader.
//
// Part of the boot block, along with bootasm.S, which calls bootmain().
// bootasm.S has put the processor into protected 32-bit mode.
// bootmain() loads an ELF kernel image from the disk starting at
// sector 1 and then jumps to the kernel entry routine.


void
bootmain(void)
{
  volatile unsigned short* vga = (volatile unsigned short*)0xB8000;

  const char* msg = "Hello World";

  while (*msg) {
    *vga++ = (0x07 << 8) | *msg++;
  }

  for (;;);
}

