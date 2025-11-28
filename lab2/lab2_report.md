# Report Lab2
- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2025/2026
- Group: K3320
- Author: Savalsky Matvey Ivanovich
- Lab: Lab1
- Date of create: 28.11.2025
- Date of finished:

## 1. Схема лабы
В drawio нарисуем схему для 2-й лабы, определим адреса сетей и интерфейсов, а также mgmt сеть. Получим:

<img width="766" height="600" alt="lab2 drawio" src="https://github.com/user-attachments/assets/613a176d-5d53-4f4e-b4c5-a25cb0ce80fc" />

## 2. Написание yml файла

Согласно вышеуказанной схеме напишем clab.yml файл:
```
name: lab2

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
    R1.MSC:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.2
      startup-config: configs/R1_MSC.rsc
    R1.BRL:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.3
      startup-config: configs/R1_BRL.rsc
    R1.FRT:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.4
      startup-config: configs/R1_FRT.rsc
    PC1:
      kind: linux
      mgmt-ipv4: 172.20.20.5
      binds:
        - configs/PC1.sh:/config.sh
      exec:
        - chmod +x /config.sh
        - /config.sh
    PC2:
      kind: linux
      mgmt-ipv4: 172.20.20.6
      binds:
        - configs/PC2.sh:/config.sh
      exec:
        - chmod +x /config.sh
        - /config.sh
    PC3:
      kind: linux
      mgmt-ipv4: 172.20.20.7
      binds:
        - configs/PC3.sh:/config.sh
      exec:
        - chmod +x /config.sh
        - /config.sh
  links:
    - endpoints: ["R1.MSC:eth1", "R1.BRL:eth1"]
    - endpoints: ["R1.MSC:eth2", "R1.FRT:eth2"]
    - endpoints: ["R1.MSC:eth3", "PC1:eth1"]
    - endpoints: ["R1.BRL:eth2", "R1.FRT:eth1"]
    - endpoints: ["R1.BRL:eth3", "PC2:eth1"]
    - endpoints: ["R1.FRT:eth3", "PC3:eth1"]
```
Получим конфигурацию:
```
╭──────────────────┬───────────────────────────────────┬───────────┬────────────────╮
│       Name       │             Kind/Image            │   State   │ IPv4/6 Address │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-PC1    │ linux                             │ running   │ 172.20.20.5    │
│                  │ alpine:3.22                       │           │ N/A            │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-PC2    │ linux                             │ running   │ 172.20.20.6    │
│                  │ alpine:3.22                       │           │ N/A            │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-PC3    │ linux                             │ running   │ 172.20.20.7    │
│                  │ alpine:3.22                       │           │ N/A            │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-R1.BRL │ vr-ros                            │ running   │ 172.20.20.3    │
│                  │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-R1.FRT │ vr-ros                            │ running   │ 172.20.20.4    │
│                  │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
├──────────────────┼───────────────────────────────────┼───────────┼────────────────┤
│ clab-lab2-R1.MSC │ vr-ros                            │ running   │ 172.20.20.2    │
│                  │ vrnetlab/mikrotik_routeros:6.47.9 │ (healthy) │ N/A            │
╰──────────────────┴───────────────────────────────────┴───────────┴────────────────╯
```
## 3. Конфиги для роутеров
Конфиги для роутеров аналогичны, меняются только адреса интерфейсов, address-pool dhcp сервера и статичные маршруты в сети других филиалов. Для Московского роутера R1_MSC:
```
/ip address
add address=9.1.0.1/30 interface=ether2
add address=9.2.0.1/30 interface=ether3
add address=192.168.1.1/24 interface=ether4

/ip pool add name=pool_msc ranges=192.168.1.10-192.168.1.254

/ip dhcp-server
network add address=192.168.1.0/24 gateway=192.168.1.1
add address-pool=pool_msc disabled=no interface=ether4 name=dhcp_msc

/ip route
add dst-address=192.168.2.0/24 gateway=9.1.0.2
add dst-address=192.168.3.0/24 gateway=9.2.0.2

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Moscow
```
Для R1_BRL:
```
/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.3.0.1/30 interface=ether3
add address=192.168.2.1/24 interface=ether4

/ip pool add name=pool_brl ranges=192.168.2.10-192.168.2.254

/ip dhcp-server
network add address=192.168.2.0/24 gateway=192.168.2.1
add address-pool=pool_brl disabled=no interface=ether4 name=dhcp_brl

/ip route
add dst-address=192.168.1.0/24 gateway=9.1.0.1
add dst-address=192.168.3.0/24 gateway=9.3.0.2

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Berlin
```
Для R1_FRT:
```
/ip address
add address=9.3.0.2/30 interface=ether2
add address=9.2.0.2/30 interface=ether3
add address=192.168.3.1/24 interface=ether4

/ip pool add name=pool_frt ranges=192.168.3.10-192.168.3.254

/ip dhcp-server
network add address=192.168.3.0/24 gateway=192.168.3.1
add address-pool=pool_frt disabled=no interface=ether4 name=dhcp_frt

/ip route
add dst-address=192.168.1.0/24 gateway=9.2.0.1
add dst-address=192.168.2.0/24 gateway=9.3.0.1

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_Frankfurt
```
## 4. Конфиги ПК
С помощью `binds` файлы конфигов с хоста будут доступны контейнерам с ПК (с помощью `chmod` делаем их исполняемыми и теперь их можно запускать). Сами конфиги одинаковы:
```
#!/bin/sh
ip route del default via 172.20.20.1
udhcpc -i eth1
```
Сначала удаляем маршрут, определяющий шлюз mgmt сети, поскольку он мешает шлюзу сети в которой находится ПК(где происходит выдача адресов с помощью dhcp). И с помощью `edhcpc -i eth1` получаем адрес на интерфейс ПК от dhcp сервера на роутере:

<img width="832" height="735" alt="image" src="https://github.com/user-attachments/assets/f017fe96-59d0-4f7f-95de-55f5f7de8e36" />


## 5. Результаты пингов
Пингуем роутеры Берлин и Франкфурт из Москвы:

<img width="755" height="296" alt="image" src="https://github.com/user-attachments/assets/33641c0a-3bba-472e-be7b-59a183903784" />

Пингуем ПК2 и ПК3 с ПК1:

<img width="794" height="496" alt="image" src="https://github.com/user-attachments/assets/334f6aaa-d63c-463e-a6bc-d20629f2aabe" />

