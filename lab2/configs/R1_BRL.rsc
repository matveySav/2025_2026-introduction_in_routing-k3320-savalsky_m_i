/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.3.0.1/30 interface=ether3
add address=192.168.2.1/24 interface=ether4

/ip pool add name=pool_brl ranges=192.168.2.10-192.168.2.254

/ip dhcp-server
network add address=192.168.2.0/24 gateway=192.168.2.1
add address-pool=pool_brl disabled=no interface=ether4 name=dhcp_brl

/ip route
add dst-address=192.168.1.0/24 gateway=9.1.0.1
add dst-address=192.168.3.0/24 gateway=9.3.0.2

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Berlin
