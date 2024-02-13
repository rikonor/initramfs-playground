TARGET_MAIN 	= x86_64-unknown-linux-musl
IMAGE_MAIN_PATH = usr/bin/main

all: rootfs init main initramfs qemu

clean:
	rm -rf \
		initramfs.cpio.gz \
		rootfs

.PHONY: rootfs
rootfs:
	docker build -f Dockerfile -o rootfs .

init:
	cp init.sh rootfs/init && \
	chmod +x rootfs/init

.PHONY: main
main:
	cd my-server && \
	cross build --target $(TARGET_MAIN) --release && \
	mv target/$(TARGET_MAIN)/release/my-server ../rootfs/$(IMAGE_MAIN_PATH) && \
	cd ..

initramfs:
	cd rootfs && \
	find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz && \
	cd ..

qemu:
	qemu-system-x86_64 -nographic -m 2048 \
		-kernel boot/bzImage \
		-initrd initramfs.cpio.gz \
		-append "console=ttyS0"
