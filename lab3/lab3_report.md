# Report Lab3
- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2025/2026
- Group: K3320
- Author: Savalsky Matvey Ivanovich
- Lab: Lab3
- Date of create: 9.12.2025
- Date of finished:

## 1. Схема лабы
В drawio нарисуем схему для 3-й лабы, определим адреса сетей и интерфейсов, mgmt сеть и loopback интерфейсы для роутеров. Получим:

<img width="1050" height="534" alt="lab3 drawio" src="https://github.com/user-attachments/assets/fd50654b-d236-464f-99e9-c4016c7e0ec9" />


## 2. Написание yml файла

Согласно вышеуказанной схеме напишем clab.yml файл:
```
name: lab3

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
    R1.NY:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.3
      startup-config: configs/R1_NY.rsc
    R1.LND:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.4
      startup-config: configs/R1_LND.rsc
    R1.LBN:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.5
      startup-config: configs/R1_LBN.rsc
    R1.HKL:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.6
      startup-config: configs/R1_HKL.rsc
    R1.MSC:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.7
      startup-config: configs/R1_MSC.rsc
    R1.SPB:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.8
      startup-config: configs/R1_SPB.rsc
    PC1:
      kind: linux
      mgmt-ipv4: 172.20.20.9
      binds:
        - configs/PC1.sh:/config.sh
      exec:
        - chmod +x /config.sh
        - /config.sh
    SGI.prism:
      kind: linux
      mgmt-ipv4: 172.20.20.2
      binds:
        - configs/SGI_prism.sh:/config.sh
      exec:
        - chmod +x /config.sh
        - /config.sh
  links:
    - endpoints: ["SGI.prism:eth1", "R1.NY:eth1"]
    - endpoints: ["R1.NY:eth2", "R1.LND:eth1"]
    - endpoints: ["R1.NY:eth3", "R1.LBN:eth1"]
    - endpoints: ["R1.LND:eth2", "R1.HKL:eth1"]
    - endpoints: ["R1.LBN:eth2", "R1.HKL:eth2"]
    - endpoints: ["R1.LBN:eth3", "R1.MSC:eth1"]
    - endpoints: ["R1.MSC:eth2", "R1.SPB:eth3"]
    - endpoints: ["R1.HKL:eth3", "R1.SPB:eth1"]
    - endpoints: ["R1.SPB:eth2", "PC1:eth1"]
```
Получим конфигурацию:
```
╭─────────────────────┬───────────────────────────────────┬───────────┬────────────────╮
│         Name        │             Kind/Image            │   State   │ IPv4/6 Address │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-PC1       │ linux                             │ running   │ 172.20.20.9    │
│                     │ alpine:3.22                       │           │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.HKL    │ vr-ros                            │ running   │ 172.20.20.6    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.LBN    │ vr-ros                            │ running   │ 172.20.20.5    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.LND    │ vr-ros                            │ running   │ 172.20.20.4    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.MSC    │ vr-ros                            │ running   │ 172.20.20.7    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.NY     │ vr-ros                            │ running   │ 172.20.20.3    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-R1.SPB    │ vr-ros                            │ running   │ 172.20.20.8    │
│                     │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├─────────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab3-SGI.prism │ linux                             │ running   │ 172.20.20.2    │
│                     │ alpine:3.22                       │           │ N/A            │
╰─────────────────────┴───────────────────────────────────┴───────────┴────────────────╯
```
## 3. Конфиги для роутеров
Конфиги роутеров аналогичны, мы выдаем ethernet интерфейсам адреса, которые определили в вышеприведенной схеме, создаем loopback интерфейс и присваеваем ему соотв. схеме ip.

После настраиваем ospf (используем дефолтную instance, добавляем сети которые будем анонсировать (адреса сетей интерфейсов и loopback роутера)). 

После этого включаем ldp и указываем интерфейсы, которые будут находиться внутри MPLS сети. В конце меняем пользователя,пароль и имя устройства.

Это общая процедура настройки всех роутеров в лабе, но надо еще настроить EoMPLS на Роутерах в Нью-Йорке и СПб, поэтому для этих роутеров мы еще создаем vpls интерфейс, даем ему идентификатор и loopback интерфейс другого роутера в качестве remote-peer, создаем мост и объединяем ethernet интерфейс выходящий из mpls сети с созданным vpls интерфейсом. Таким образом создается виртуальное L2 соединение (pseudoWire) между этими роутерами поверх IP/MPLS сети. Ниже  конфигурации роутеров NY и LND:

Для `R1_NY`:
```
/ip address
add address=192.168.1.1/24 interface=ether2
add address=9.1.0.1/30 interface=ether3
add address=9.2.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=1.1.1.1/32 interface=lo

/routing ospf instance set default router-id=1.1.1.1
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.2.0.0/30 area=backbone
add network=192.168.1.0/24 area=backbone 
add network=1.1.1.1/32 area=backbone

/mpls ldp set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
/mpls ldp interface
add interface=ether3
add interface=ether4

/interface vpls add name=vpws cisco-style=yes cisco-style-id=10 disabled=no remote-peer=6.6.6.6
/interface bridge add name=vpn
/interface bridge port
add bridge=vpn interface=ether2
add bridge=vpn interface=vpws

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_New_York
```

Для `R1_LND`:
```
/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.3.0.1/30 interface=ether3

/interface bridge add name=lo
/ip address add address=2.2.2.2/32 interface=lo

/routing ospf instance set default router-id=2.2.2.2
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.3.0.0/30 area=backbone
add network=2.2.2.2/32 area=backbone

/mpls ldp set enabled=yes lsr-id=2.2.2.2 transport-address=2.2.2.2
/mpls ldp interface
add interface=ether2
add interface=ether3

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_London
```
## 4. Конфиги ПК
С помощью `binds` файлы конфигов с хоста будут доступны контейнерам с ПК (с помощью `chmod` делаем их исполняемыми и теперь их можно запускать). Сами конфиг: задаем статически ip и дефолтный шлюз:
Для `SGI.prism`:
```
#!/bin/sh

ifconfig eth1 192.168.1.254 netmask 255.255.255.0
route add default gw 192.168.1.1 eth1
```
Для `PC1`:
```
#!/bin/sh

ifconfig eth1 192.168.2.254 netmask 255.255.255.0
route add default gw 192.168.2.1 eth1
```
## 5. LDP соседи
Это чтобы показать, что IP/MPLS + EoMPLS (6.6.6.6 LSR будет соседом 1.1.1.1 LSR и наоборот) правильно настроилось
NY:
<img width="928" height="364" alt="image" src="https://github.com/user-attachments/assets/bcb4257a-874f-45b3-8eed-57d09b77444f" />
SPB:
<img width="928" height="364" alt="image" src="https://github.com/user-attachments/assets/b5a430cd-0cd8-4450-a677-49bf358f0e3e" />

Ну и R1_LBN, чтобы убедиться, что остальные роутеры в сети также правильно нашли соседей:
<img width="928" height="364" alt="image" src="https://github.com/user-attachments/assets/6e870585-accc-4805-842e-ef7e112e0241" />

## 6. Таблицы маршрутизации на роутерах (и LFIB таблицы для меток MPLS)
NY:
<img width="1773" height="862" alt="image" src="https://github.com/user-attachments/assets/033b4a1d-c827-4a3a-abe0-4e568ae085b8" />

LND:
<img width="1773" height="862" alt="image" src="https://github.com/user-attachments/assets/ce90f5cb-be64-4bce-84e6-4d3813e6b49c" />

LBN:
<img width="1773" height="822" alt="image" src="https://github.com/user-attachments/assets/17580ffa-26a1-45cc-a0b8-a98231b11390" />

HLK:
<img width="1773" height="822" alt="image" src="https://github.com/user-attachments/assets/372894dc-4c19-45fc-950b-263d48346560" />

MSC:
<img width="1773" height="836" alt="image" src="https://github.com/user-attachments/assets/7b9f080c-3511-47b6-af2c-ce6c91981e73" />

SPB:
<img width="1773" height="858" alt="image" src="https://github.com/user-attachments/assets/21b09b26-866b-430b-8fbc-f820a48eb70e" />

## 7. Пинг между PC1 и SGI_prism
От SGI_prism -> PC1:
<img width="912" height="595" alt="image" src="https://github.com/user-attachments/assets/97b26ad7-6130-4c40-b0cd-d65ec8614613" />

Наоборот: 
<img width="906" height="546" alt="image" src="https://github.com/user-attachments/assets/a7c9a29b-fba0-406f-8acf-707aa55fc255" />


<img width="794" height="496" alt="image" src="https://github.com/user-attachments/assets/334f6aaa-d63c-463e-a6bc-d20629f2aabe" />

