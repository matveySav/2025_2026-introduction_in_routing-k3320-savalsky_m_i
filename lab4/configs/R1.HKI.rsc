/ip address
add address=9.2.0.2/30 interface=ether2
add address=9.3.0.1/30 interface=ether3
add address=9.5.0.2/30 interface=ether4

/interface bridge add name=lo
/ip address add address=3.3.3.3/32 interface=lo

/routing ospf instance set default router-id=3.3.3.3
/routing ospf network 
add network=9.2.0.0/30 area=backbone
add network=9.3.0.0/30 area=backbone
add network=9.5.0.0/30 area=backbone
add network=3.3.3.3/32 area=backbone

/mpls ldp set enabled=yes lsr-id=3.3.3.3 transport-address=3.3.3.3
/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp instance set default as=65000 router-id=3.3.3.3 cluster-id=3.3.3.3
/routing bgp peer
add name=LND remote-address=2.2.2.2 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
add name=LBN remote-address=5.5.5.5 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
add name=SPB remote-address=4.4.4.4 remote-as=65000 route-reflect=yes update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
/routing bgp network 
add network=9.2.0.0/30 
add network=9.3.0.0/30
add network=9.5.0.0/30

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Helsinki
