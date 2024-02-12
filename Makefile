all: rootfs init initramfs qemu

clean:
	rm -rf rootfs && \
	rm initramfs.cpio.gz

.PHONY: rootfs
rootfs:
	docker build -f Dockerfile -o rootfs .

init:
	cp init.sh rootfs/init && \
	chmod +x rootfs/init

initramfs:
	cd rootfs && \
	find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz && \
	cd ..

qemu:
	qemu-system-x86_64 -nographic -m 2048 \
		-kernel boot/bzImage \
		-initrd initramfs.cpio.gz \
		-append "console=ttyS0"
