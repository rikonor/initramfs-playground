#!/bin/sh

mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

ip link set eth0 up
udhcpc -i eth0

/usr/bin/main
