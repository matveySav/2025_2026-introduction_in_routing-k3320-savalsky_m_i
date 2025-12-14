/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.2.0.1/30 interface=ether3
add address=9.4.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=2.2.2.2/32 interface=lo

/routing ospf instance set default router-id=2.2.2.2
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.2.0.0/30 area=backbone
add network=9.4.0.0/30 area=backbone
add network=2.2.2.2/32 area=backbone

/mpls ldp set enabled=yes lsr-id=2.2.2.2 transport-address=2.2.2.2
/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp instance set default as=65000 router-id=2.2.2.2 cluster-id=2.2.2.2
/routing bgp peer
add name=NY remote-address=1.1.1.1 remote-as=65000 route-reflect=yes update-source=lo \
address-families=ip,vpnv4
add name=LBN remote-address=5.5.5.5 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4
add name=HKI remote-address=3.3.3.3 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4
/routing bgp network 
add network=9.1.0.0/30 
add network=9.4.0.0/30
add network=9.2.0.0/30

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_London
