/ip address
add address=9.6.0.2/30 interface=ether3
add address=192.168.3.1/24 interface=ether2

/interface bridge add name=lo
/ip address add address=6.6.6.6/32 interface=lo

/routing ospf instance set default router-id=6.6.6.6
/routing ospf network 
add network=9.6.0.0/30 area=backbone
add network=6.6.6.6/32 area=backbone

/mpls ldp set enabled=yes lsr-id=6.6.6.6 transport-address=6.6.6.6
/mpls ldp interface
add interface=ether3

/routing bgp instance set default as=65000 router-id=6.6.6.6
/routing bgp peer
add name=LBN remote-address=5.5.5.5 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4
/routing bgp network 
add network=9.6.0.0/30 

/ip route vrf add disabled=no routing-mark=devops route-distinguisher=1.1.1.1:100 \ 
export-route-targets=1.1.1.1:100 import-route-targets=1.1.1.1:100 interfaces=ether2
/routing bgp instance vrf add instance=default routing-mark=devops redistribute-connected=yes

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Savonlinna
