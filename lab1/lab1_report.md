# Report Lab1
- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2025/2026
- Group: K3320
- Author: Savalsky Matvey Ivanovich
- Lab: Lab1
- Date of create: 26.11.2025
- Date of finished:

## 1. Схема лабы
Выберем диапазоны (и сами адреса сетевых устройств) сетей mgmt и 2х VLANов, а также интерфейсы подключения (в linux конвенции) схема выглядит следующим образом:

<img width="541" height="520" alt="lab1 drawio" src="https://github.com/user-attachments/assets/29fac76b-232f-4de0-8680-0ddc081c5b88" />

Получится следующая конфигурация:
```
╭──────────────────────┬───────────────────────────────────┬───────────┬────────────────╮
│         Name         │             Kind/Image            │   State   │ IPv4/6 Address │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-PC1        │ linux                             │ running   │ 172.20.20.6    │
│                      │ alpine:3.22                       │           │ N/A            │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-PC2        │ linux                             │ running   │ 172.20.20.7    │
│                      │ alpine:3.22                       │           │ N/A            │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-R01        │ vr-ros                            │ running   │ 172.20.20.2    │
│                      │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-SW01.L3.01 │ vr-ros                            │ running   │ 172.20.20.3    │
│                      │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-SW02.L3.01 │ vr-ros                            │ running   │ 172.20.20.4    │
│                      │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├──────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab1-SW02.L3.02 │ vr-ros                            │ running   │ 172.20.20.5    │
│                      │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
╰──────────────────────┴───────────────────────────────────┴───────────┴────────────────╯
```
## 2. Написание yaml файла
Выделяем mgmt сеть, каждому ноду отдельно пропишем адрес для удобства, сократим написание файла как можно (с помощью kinds), пропишем линки согласно структуре задания. Применим кониги при старте лабы с помощью `startup-config` для свитчей и роутера и `exec` для ПК. Сами конфиги дальше
```
name: lab1

mgmt:
  network: custom_mgmt
  ipv4-subnet: 172.20.20.0/24

topology:
  kinds:
    vr-ros:
      image: vrnetlab/mikrotik_routeros:6.47.9
    linux:
      image: alpine:3.22
  nodes:
    R01:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.2
      startup-config: scripts/R01_setup.rsc
    SW01.L3.01:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.3
      startup-config: scripts/SW01_L3_01_setup.rsc
    SW02.L3.01:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.4
      startup-config: scripts/SW02_L3_01_setup.rsc
    SW02.L3.02:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.5
      startup-config: scripts/SW02_L3_02_setup.rsc
    PC1:
      kind: linux
      mgmt-ipv4: 172.20.20.6
      exec:
        - udhcpc -i eth1
        - ip route add 10.20.0.0/24 via 10.10.0.1
    PC2:
      kind: linux
      mgmt-ipv4: 172.20.20.7
      exec:
        - udhcpc -i eth1
        - ip route add 10.10.0.0/24 via 10.20.0.1
  links:
    - endpoints: ["R01:eth1", "SW01.L3.01:eth1"]
    - endpoints: ["SW01.L3.01:eth2", "SW02.L3.01:eth1"]
    - endpoints: ["SW01.L3.01:eth3", "SW02.L3.02:eth1"]
    - endpoints: ["SW02.L3.01:eth2", "PC1:eth1"]
    - endpoints: ["SW02.L3.02:eth2", "PC2:eth1"]

```
## 3. Конфиг Роутера R01
Пропишем vlan'ы для интерфейса привяжем к ним ip согласно вышеуказанной схеме. Также определим пулы ip адресов и соотв. подсети для настройки dhcp. Добавим dhcp каждому VLAN'у и поменяем пользователя, пароль и имя устройства, удалим пользователь admin.
```
/interface vlan
add name=vlan10 vlan-id=10 interface=ether2 disabled=no
add name=vlan20 vlan-id=20 interface=ether2 disabled=no

/ip address
add address=10.10.0.1/24 interface=vlan10
add address=10.20.0.1/24 interface=vlan20

/ip pool 
add name=dhcp_vlan10 ranges=10.10.0.10-10.10.0.254
add name=dhcp_vlan20 ranges=10.20.0.10-10.20.0.254

/
/ip dhcp-server 
add address-pool=dhcp_vlan10 disabled=no interface=vlan10 name=dhcp10
add address-pool=dhcp_vlan20 disabled=no interface=vlan20 name=dhcp20
network add address=10.10.0.0/24 gateway=10.10.0.1
network add address=10.20.0.0/24 gateway=10.20.0.1

/user add name=custom password=custom group=full
/user remove admin
/system identity set name=R1
```
## 4. Центральный свитч SW01.L3.01
Объединяем порты в мост, прописываем trunk порты, с помощью `/interface bridge vlan` указываем интерфейсы тэгированного трафика и соотв им vlan id (поскольку создаем `/interface vlan` и выдаем им ip поверх моста, надо указать сам мост в `tagged=...`, чтобы работало на L3). Включаем vlan фильтрацию, и аналогично меняем пользователя,пароль и имя девайса
```
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
```
## 5. Свитчи среднего уровня SW02.L3.01/2
Настраиваются анаолгична, т.к. сеть симметрична. Здесь также объединяем порты в мост, выделяя access порты (в pvid указываем соотв. vlan id). Остальное аналогично

Для SW2_1:
```
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
```
## 6. Настройка ПК, получение ip от dhcp сервера на роутере
С помощью `udhcpc -i eth1` получаем ip адрес от соотв. dhcp сервера при правильно настроенной сети. Чтобы ПК видели друг друга добавляем маршрут `ip route add 10.x0.0.0/24 via 10.y0.0.1`, чтобы ПК через роутер могли сходить в другой VLAN. В результате получаем ip из указанного нами диапазона

<img width="867" height="512" alt="image" src="https://github.com/user-attachments/assets/a3ab5fac-779e-4384-b849-0c03df3085ee" />

Пинг от ПК1 к ПК2:

<img width="714" height="460" alt="image" src="https://github.com/user-attachments/assets/32d4630d-622e-4b24-8515-30e8786f9ea2" />

Пинг от роутера к свитчам:

<img width="770" height="698" alt="image" src="https://github.com/user-attachments/assets/cde53889-bdda-42c1-86e6-e9f91017de15" />

Пинг ПК с роутера:

<img width="760" height="310" alt="image" src="https://github.com/user-attachments/assets/8dbeaaed-3fb0-406c-9694-a9a3fa3df685" />
