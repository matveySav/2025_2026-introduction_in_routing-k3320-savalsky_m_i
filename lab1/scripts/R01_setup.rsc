/interface vlan
add name=vlan10 vlan-id=10 interface=ether2 disabled=no
add name=vlan20 vlan-id=20 interface=ether2 disabled=no

/ip address
add address=10.10.0.1/24 interface=vlan10
add address=10.20.0.1/24 interface=vlan20

/ip pool 
add name=dhcp_vlan10 ranges=10.10.0.10-10.10.0.254
add name=dhcp_vlan20 ranges=10.20.0.10-10.20.0.254

/
/ip dhcp-server 
add address-pool=dhcp_vlan10 disabled=no interface=vlan10 name=dhcp10
add address-pool=dhcp_vlan20 disabled=no interface=vlan20 name=dhcp20
network add address=10.10.0.0/24 gateway=10.10.0.1
network add address=10.20.0.0/24 gateway=10.20.0.1

/user add name=custom password=custom group=full
/user remove admin
/system identity set name=R1
