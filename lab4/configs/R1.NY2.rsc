/ip address
add address=9.1.0.1/30 interface=ether3

/interface bridge add name=lo
/ip address add address=1.1.1.1/32 interface=lo

/routing ospf instance set default router-id=1.1.1.1
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=1.1.1.1/32 area=backbone

/mpls ldp set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
/mpls ldp interface
add interface=ether3

/routing bgp instance set default as=65000 router-id=1.1.1.1
/routing bgp peer
add name=LND remote-address=2.2.2.2 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,l2vpn
/routing bgp network 
add network=9.1.0.0/30 

/interface bridge add name=vpn
/interface bridge port add bridge=vpn interface=ether2

/interface vpls bgp-vpls add bridge=vpn route-distinguisher=1:1 site-id=1 \
import-route-targets=1:1 export-route-targets=1:1

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_New_York
