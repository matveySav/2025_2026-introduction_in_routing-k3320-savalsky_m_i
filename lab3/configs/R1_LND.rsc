/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.3.0.1/30 interface=ether3

/interface bridge add name=lo
/ip address add address=2.2.2.2/32 interface=lo

/routing ospf instance set default router-id=2.2.2.2
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.3.0.0/30 area=backbone
add network=2.2.2.2/32 area=backbone

/mpls ldp set enabled=yes lsr-id=2.2.2.2 transport-address=2.2.2.2
/mpls ldp interface
add interface=ether2
add interface=ether3

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_London
