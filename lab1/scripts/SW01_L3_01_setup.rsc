/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether2 frame-types=admit-only-vlan-tagged
add bridge=bridge1 interface=ether3 frame-types=admit-only-vlan-tagged
add bridge=bridge1 interface=ether4 frame-types=admit-only-vlan-tagged

/interface bridge vlan
add bridge=bridge1 tagged=ether2,ether3,bridge1 vlan-ids=10
add bridge=bridge1 tagged=ether2,ether4,bridge1 vlan-ids=20

/interface vlan
add name=vlan10 vlan-id=10 interface=bridge1
add name=vlan20 vlan-id=20 interface=bridge1

/ip address
add address=10.10.0.2/24 interface=vlan10
add address=10.20.0.2/24 interface=vlan20

/user add name=custom password=custom group=full
/user remove admin

/system identity set name=SW1_1
