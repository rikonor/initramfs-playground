#!/bin/sh

ip link set eth0 up
udhcpc -i eth0

# /bin/sh +m

/usr/bin/main

