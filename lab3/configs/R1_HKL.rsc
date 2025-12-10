/ip address
add address=9.3.0.2/30 interface=ether2
add address=9.4.0.1/30 interface=ether3
add address=9.6.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=4.4.4.4/32 interface=lo

/routing ospf instance set default router-id=4.4.4.4
/routing ospf network 
add network=9.3.0.0/30 area=backbone
add network=9.4.0.0/30 area=backbone
add network=9.6.0.0/30 area=backbone 
add network=4.4.4.4/32 area=backbone

/mpls ldp set enabled=yes lsr-id=4.4.4.4 transport-address=4.4.4.4
/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Helsinki
