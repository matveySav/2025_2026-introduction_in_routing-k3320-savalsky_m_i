/ip address
add address=9.3.0.2/30 interface=ether2
add address=192.168.2.1/24 interface=ether3

/interface bridge add name=lo
/ip address add address=4.4.4.4/32 interface=lo

/routing ospf instance set default router-id=4.4.4.4
/routing ospf network 
add network=9.3.0.0/30 area=backbone
add network=4.4.4.4/32 area=backbone

/mpls ldp set enabled=yes lsr-id=4.4.4.4 transport-address=4.4.4.4
/mpls ldp interface
add interface=ether2

/routing bgp instance set default as=65000 router-id=4.4.4.4
/routing bgp peer
add name=HKI remote-address=3.3.3.3 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4 nexthop-choice=force-self
/routing bgp network 
add network=9.3.0.0/30 

/ip route vrf add disabled=no routing-mark=devops route-distinguisher=1.1.1.1:100 \ 
export-route-targets=1.1.1.1:100 import-route-targets=1.1.1.1:100 interfaces=ether3
/routing bgp instance vrf add instance=default routing-mark=devops redistribute-connected=yes

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Saint_Petersburg

