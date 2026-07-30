SRC_DIR = ./src
OBJ_DIR = ./obj

TARGET_IMAGE = ./disk.img

ASM = nasm
AFLAGS = -f bin

# Note that the order here defines the order they will be in inside disk.img
AOBJS = $(OBJ_DIR)/boot.o $(OBJ_DIR)/initsysfn.o $(OBJ_DIR)/fssignature.o $(OBJ_DIR)/dm.o

.PHONY: all
all: build

.PHONY: qemu
qemu: run

.PHONY: run
run: build
	qemu-system-i386 -drive format=raw,file=$(TARGET_IMAGE)
	
.PHONY: build
build: $(OBJ_DIR) disk.img

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

disk.img: $(AOBJS)
	@echo "Creating disk image..."
	@cat $(AOBJS) > disk.img
	@echo "Done."

$(OBJ_DIR)/fssignature.o:
	@echo "Generating fssignature.o"
	@printf "\x01\x13" > $@
	@dd if=/dev/zero bs=1 count=510 >> $@ 2>/dev/null
	
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	@echo "ASM $<"
	@$(ASM) $(AFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)
	rm -f $(TARGET_IMAGE)
