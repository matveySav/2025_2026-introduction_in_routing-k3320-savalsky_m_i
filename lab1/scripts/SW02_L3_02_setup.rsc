/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether2 frame-types=admit-only-vlan-tagged 
add bridge=bridge1 interface=ether3 pvid=20 frame-types=admit-only-untagged-and-priority-tagged

/interface bridge vlan
add bridge=bridge1 tagged=ether2,bridge1 vlan-ids=20

/interface vlan
add interface=bridge1 name=vlan20 vlan-id=20

/ip address
add address=10.20.0.3/24 interface=vlan20

/user add name=custom password=custom group=full
/user remove admin

/system identity set name=SW2_2
