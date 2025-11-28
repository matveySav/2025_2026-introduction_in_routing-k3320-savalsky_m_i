#!/bin/sh

ip route del default via 172.20.20.1
udhcpc -i eth1
