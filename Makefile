CC=gcc
AS=as
LD=ld
KERNEL_IMG=myos.bin

CFLAGS = -Wall -Wno-int-conversion -fstrength-reduce -m32 -fomit-frame-pointer -finline-functions -nostdlib -ffreestanding -I ./include -I ./kernel
ASFLAGS = --32 -ggdb
LDFLAGS = $(CFLAGS)

## END CONFIGURABLE ##

## Gather the necessary assembly files
ASM_FILES=$(shell ls kernel/*.s) $(shell ls kernel/*/*.s)
ASM_OBJ=$(patsubst kernel/%.s,kernel/%.o,$(ASM_FILES))

## Gather the necessary C files
CFILES=$(shell ls kernel/*.c) $(shell ls kernel/*/*.c) $(shell ls kernel/*/*/*.c)
C_OBJ=$(patsubst kernel/%.c,kernel/%.o,$(CFILES))

OBJECTS=$(ASM_OBJ) $(C_OBJ)
all: $(KERNEL_IMG)

clean:
	find . -type f | xargs touch
	-@rm $(OBJECTS)

nuke: clean
	-@rm $(KERNEL_IMG)
	-@rm f32.disk

run: iso
	export QEMU_AUDIO_DRV=alsa
	qemu-system-i386 -cdrom myos.iso -m size=512 -vga std \
	-soundhw hda,pcspk,ac97 -serial stdio -usb -boot d

qemu: $(KERNEL_IMG) initrd.img
	export QEMU_AUDIO_DRV=alsa
	qemu-system-i386 -kernel myos.bin -initrd initrd.img -vga std -s -soundhw pcspk -m size=128 \
	-serial stdio \
	-boot d \

initrd.img:
	python2 create_initrd.py

run-debug: $(KERNEL_IMG)
	@echo "gdb target localhost:1234"
	qemu-system-i386 --kernel $(KERNEL_IMG)

hda.iso:
	-rm hda.iso
	dd if=/dev/zero of=hda.iso bs=1M count=100
	mkfs.fat -F32 hda.iso -s 1

mount_disk: hda.iso
	mkdir -p fat32
	sudo mount -rw hda.iso fat32
	
populate_disk: mount_disk
	sudo cp *.c *.h fat32
	sudo cp -R deps fat32/
	sudo mkdir -p fat32/foo/bar/baz/boo/dep/doo/poo/goo/
	sudo cp common.h fat32/foo/bar/baz/boo/dep/doo/poo/goo/tood.txt
	sleep 1
	sudo umount fat32
	-@rm -Rf fat32

$(KERNEL_IMG) : $(OBJECTS) linker.ld
	$(LD) -m elf_i386 -nostdlib -T linker.ld -o myos.bin $(OBJECTS)

iso: $(KERNEL_IMG)
	mkdir -p isodir/boot/grub
	echo "menuentry 'ChiptuneOS 0.1' { multiboot /boot/myos.bin }" << isodir/boot/grub/grub.cfg
	cp myos.bin isodir/boot/
	#cp initrd.img isodir/boot
	grub-mkrescue isodir -o myos.iso

## Generic assembly rule
#%.o: %.s
#	$(AS) $(AFLAGS) $< -o $@

deps/%.d : %.c
	@mkdir -p deps
	@mkdir -p `dirname $@`
	@echo -e "[MM]\t\t" $@
	@$(CC) $(CFLAGS) -MM $< -MF $@
