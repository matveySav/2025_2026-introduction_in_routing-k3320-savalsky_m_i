/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether2 frame-types=admit-only-vlan-tagged 
add bridge=bridge1 interface=ether3 pvid=10 frame-types=admit-only-untagged-and-priority-tagged

/interface bridge vlan
add bridge=bridge1 tagged=bridge1,ether2 vlan-ids=10

/interface vlan
add interface=bridge1 name=vlan10 vlan-id=10

/ip address
add address=10.10.0.3/24 interface=vlan10

/user add name=custom password=custom group=full
/user remove admin

/system identity set name=SW2_1
