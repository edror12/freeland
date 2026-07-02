# CC = gcc
# AS = gas
# LD = ld
# LDFLAGS = -m elf_i386
# OBJCOPY = objcopy
# OBJDUMP = objdump
# CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -fno-omit-frame-pointer
# CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

CC       = clang
LD       = ld.lld
OBJCOPY  = llvm-objcopy
OBJDUMP  = llvm-objdump

LDFLAGS  = -m elf_i386 --image-base=0

CFLAGS   = -fno-pic \
            -static \
            -fno-builtin \
            -fno-strict-aliasing \
            -O2 \
            -Wall \
            -MD \
            -ggdb \
            -m32 \
            -fno-omit-frame-pointer

CFLAGS  += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

# VERBOSE:
#   When not specified, suppress normal makefile output for a more terse version
#   of the output.  But, allow a user to see the full makefile output when this
#   option is specified.
ifneq ($(VERBOSE), 1)
    brief = @echo "[$(patsubst $(OBJ_DIR)/%,%,$(@))]";
    verb = @
else
    brief = @echo "";
    verb =
endif

bootblock: bootloader/bootasm.S bootloader/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I./include -c bootloader/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I./include -c bootloader/bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o bootasm.o bootmain.o
	$(OBJDUMP) -S bootblock.o > bootblock.asm
	$(OBJCOPY) -S -O binary -j .text -j .rodata bootblock.o bootblock
	./bootloader/sign.sh bootblock

