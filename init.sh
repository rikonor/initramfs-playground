#!/bin/sh

mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

# Configure network
ip link set eth0 up
udhcpc -i eth0

# Start init
exec runsvdir -P /etc/service
