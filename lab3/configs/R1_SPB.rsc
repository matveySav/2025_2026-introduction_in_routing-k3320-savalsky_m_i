/ip address
add address=9.6.0.2/30 interface=ether2
add address=9.7.0.2/30 interface=ether4

/interface bridge add name=lo
/ip address add address=6.6.6.6/32 interface=lo

/routing ospf instance set default router-id=6.6.6.6
/routing ospf network 
add network=9.6.0.0/30 area=backbone
add network=9.7.0.0/30 area=backbone
add network=6.6.6.6/32 area=backbone

/mpls ldp set enabled=yes lsr-id=6.6.6.6 transport-address=6.6.6.6
/mpls ldp interface
add interface=ether2
add interface=ether4

/interface vpls add name=vpws cisco-style=yes cisco-style-id=10 disabled=no remote-peer=1.1.1.1
/interface bridge add name=vpn
/interface bridge port
add bridge=vpn interface=ether3
add bridge=vpn interface=vpws

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Saint_Petersburg
