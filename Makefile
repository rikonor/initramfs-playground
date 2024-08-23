TARGET_MAIN 	= x86_64-unknown-linux-musl
IMAGE_MAIN_PATH = usr/bin/main

QEMU_BIN ?= qemu-system-x86_64

all: initramfs qemu

clean:
	rm -rf \
		initramfs.cpio.gz \
		rootfs

.PHONY: rootfs
rootfs:
	docker build -f Dockerfile -o rootfs .

.PHONY: main
main:
	cd my-server && \
	cross build --target $(TARGET_MAIN) --release && \
	mv target/$(TARGET_MAIN)/release/my-server ../rootfs/$(IMAGE_MAIN_PATH) && \
	cd ..

initramfs: clean rootfs main
	cd rootfs && \
	find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz && \
	cd ..

qemu:
	$(QEMU_BIN) \
		-enable-kvm -m 2G \
		-kernel boot/vmlinuz-6.9.0-snp-guest-a38297e -append "console=ttyS0" \
		-initrd initramfs.cpio.gz \
		-nographic -serial stdio -nodefaults \
		-device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::3000-:3000
