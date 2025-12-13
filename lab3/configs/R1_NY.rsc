/ip address
add address=9.1.0.1/30 interface=ether3
add address=9.2.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=1.1.1.1/32 interface=lo

/routing ospf instance set default router-id=1.1.1.1
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.2.0.0/30 area=backbone
add network=1.1.1.1/32 area=backbone

/mpls ldp set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
/mpls ldp interface
add interface=ether3
add interface=ether4

/interface vpls add name=vpws cisco-style=yes cisco-style-id=10 disabled=no remote-peer=6.6.6.6
/interface bridge add name=vpn
/interface bridge port
add bridge=vpn interface=ether2
add bridge=vpn interface=vpws

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_New_York
