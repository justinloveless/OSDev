
KERNEL_DIR = kernel
DRIVER_DIR = drivers
OBJ_DIR = objects
OBJS = objects\kernel.o objects\kernel_entry.o objects\low_level.o objects\screen.o objects\keyboard.o
DISASMS = kernel\kernel.dis


# {$(SOURCE_DIR)}.SOURCE_EXTENSION{$(OUTPUT_DIR)}.OUTPUT_ENTENSION:
{$(KERNEL_DIR)}.c.o:
	echo making $@
#	using $* includes the target directory, so use $(*B) to get the base name, 
# 	then add $(KERNEL_DIR) to put the source directory back
	gcc -ffreestanding -c $(KERNEL_DIR)\$(*B).c -o $@
	
{$(KERNEL_DIR)}.o.tmp:
	echo making $@
	ld -Ttext 0x1000 $*.o -o $@
	
{$(DRIVER_DIR)}.c.o:
	echo making $@
	gcc -ffreestanding -c $(DRIVER_DIR)\$(*B).c -o $@
	
{$(KERNEL_DIR)}.asm.o:
	echo making $@
	nasm-2.12.02\nasm $(KERNEL_DIR)\$(*B).asm -f elf -o $@

# default make target
all : os-image $(DISASMS)

kernel\kernel.tmp : $(OBJS)
	ld -o $@ -Ttext 0x1000 $**
	
# build kernal binary file. Requires kernel.tmp
bin\kernel.bin : kernel\kernel.tmp
	objcopy -O binary "kernel\kernel.tmp" "bin\kernel.bin"
	
boot\boot_sect.bin : boot\JLOS.asm
	nasm-2.12.02\nasm "boot\JLOS.asm" -f bin -o "bin\boot_sect.bin"

.PHONY : clean
clean :
	del $(OBJS) "kernel\*.tmp" "kernel\*.dis" "bin\*" "disasm\*.dis" /Q
	
run : all 
	"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "MyBootLoader"
	
# concatenate the kernel on after the boot sector
os-image : DiskFrontMatter boot\boot_sect.bin bin\kernel.bin
	type "DiskFrontMatter" "bin\boot_sect.bin" "bin\kernel.bin" > "os-image.vdi"
	
#For debugging: generate a disassembly file
kernel\kernel.dis : bin\kernel.bin
	ndisasm -b 32 "bin\kernel.bin" > "disasm\kernel.dis"
	