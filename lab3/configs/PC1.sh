#!/bin/sh

ifconfig eth1 192.168.2.254 netmask 255.255.255.0
route add default gw 192.168.2.1 eth1
