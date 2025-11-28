/ip address
add address=9.1.0.1/30 interface=ether2
add address=9.2.0.1/30 interface=ether3
add address=192.168.1.1/24 interface=ether4

/ip pool add name=pool_msc ranges=192.168.1.10-192.168.1.254

/ip dhcp-server
network add address=192.168.1.0/24 gateway=192.168.1.1
add address-pool=pool_msc disabled=no interface=ether4 name=dhcp_msc

/ip route
add dst-address=192.168.2.0/24 gateway=9.1.0.2
add dst-address=192.168.3.0/24 gateway=9.2.0.2

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Moscow
