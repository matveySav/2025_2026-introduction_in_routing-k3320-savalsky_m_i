/ip address
add address=9.4.0.2/30 interface=ether2
add address=9.5.0.1/30 interface=ether3
add address=9.6.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=5.5.5.5/32 interface=lo

/routing ospf instance set default router-id=5.5.5.5
/routing ospf network 
add network=9.4.0.0/30 area=backbone
add network=9.5.0.0/30 area=backbone
add network=9.6.0.0/30 area=backbone
add network=5.5.5.5/32 area=backbone

/mpls ldp set enabled=yes lsr-id=5.5.5.5 transport-address=5.5.5.5
/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp instance set default as=65000 router-id=5.5.5.5 cluster-id=5.5.5.5
/routing bgp peer
add name=LND remote-address=2.2.2.2 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
add name=HKI remote-address=3.3.3.3 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
add name=SVL remote-address=6.6.6.6 remote-as=65000 route-reflect=yes update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
/routing bgp network 
add network=9.5.0.0/30 
add network=9.4.0.0/30
add network=9.6.0.0/30

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Lebanon
