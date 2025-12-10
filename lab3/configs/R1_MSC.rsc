/ip address
add address=9.5.0.2/30 interface=ether2
add address=9.7.0.1/30 interface=ether3

/interface bridge add name=lo
/ip address add address=5.5.5.5/32 interface=lo

/routing ospf instance set default router-id=5.5.5.5
/routing ospf network 
add network=9.5.0.0/30 area=backbone
add network=9.7.0.0/30 area=backbone
add network=5.5.5.5/32 area=backbone

/mpls ldp set enabled=yes lsr-id=5.5.5.5 transport-address=5.5.5.5
/mpls ldp interface
add interface=ether2
add interface=ether3

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Moscow
