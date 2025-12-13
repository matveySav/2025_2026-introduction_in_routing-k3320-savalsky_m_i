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
В drawio нарисуем схему для 3-й лабы, определим адреса сетей и интерфейсов, mgmt сеть и loopback интерфейсы для роутеров, выберем адреса для ПК в одной сети. Получим:

<img width="1071" height="554" alt="lab3 drawio" src="https://github.com/user-attachments/assets/1517a56a-2ce5-47ec-b65d-63afba7b45bf" />

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
      exec:
        - ifconfig eth1 192.168.1.2 netmask 255.255.255.0
    SGI.prism:
      kind: linux
      mgmt-ipv4: 172.20.20.2
      exec:
        - ifconfig eth1 192.168.1.1 netmask 255.255.255.0
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

После настраиваем ospf (используем дефолтную instance, добавляем сети которые будем анонсировать (+ loopback роутера)). 

После этого включаем ldp и указываем интерфейсы, которые будут находиться внутри MPLS сети. В конце меняем пользователя,пароль и имя устройства.

Это общая процедура настройки всех роутеров в лабе, но надо еще настроить EoMPLS на Роутерах в Нью-Йорке и СПб, поэтому для этих роутеров мы еще создаем vpls интерфейс, даем ему идентификатор и loopback интерфейс другого роутера в качестве remote-peer, создаем мост и объединяем ethernet интерфейс выходящий из mpls сети с созданным vpls интерфейсом. Таким образом создается виртуальное L2 соединение (pseudoWire) между этими роутерами поверх IP/MPLS сети. Ниже  конфигурации роутеров NY и LND:

Для `R1_NY`:
```
/ip address
add address=9.1.0.1/30 interface=ether3
add address=9.2.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=1.1.1.1/32 interface=lo

/routing ospf instance set default router-id=1.1.1.1
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.2.0.0/30 area=backbone
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
Прописываем статичный ip ПК1 и SGI_prism в одной сети

Для `SGI.prism`: `ifconfig eth1 192.168.1.1 netmask 255.255.255.0`

Для `PC1`: `ifconfig eth1 192.168.1.2 netmask 255.255.255.0`

## 5. LDP соседи
Это чтобы показать, что IP/MPLS + EoMPLS (6.6.6.6 LSR будет соседом 1.1.1.1 LSR и наоборот) правильно настроилось

`NY`:

<img width="994" height="309" alt="image" src="https://github.com/user-attachments/assets/d57bb3b6-bb46-42df-bd61-ef37a946b585" />

`SPB`:

<img width="994" height="309" alt="image" src="https://github.com/user-attachments/assets/3224ed5c-8539-457a-84f5-a4266f63ae5d" />

Ну и `R1_LBN`, чтобы убедиться, что остальные роутеры в сети также правильно нашли соседей:

<img width="994" height="309" alt="image" src="https://github.com/user-attachments/assets/a24d89bc-28fa-4887-b37f-5c8a1a2f6968" />

Также можно прямо посмотреть на vpls интерфейс через `interface vpls monitor`:
На `R1_NY`:

<img width="567" height="170" alt="image" src="https://github.com/user-attachments/assets/280beaf3-8715-43ff-be9e-239b576a483c" />

На `R1_SPB`:

<img width="620" height="176" alt="image" src="https://github.com/user-attachments/assets/fea6755b-0250-49d5-b3b2-839ade44520a" />

## 6. Таблицы маршрутизации на роутерах (и LFIB таблицы для меток MPLS)
`NY`:

<img width="1138" height="789" alt="image" src="https://github.com/user-attachments/assets/9c6ab362-0da4-4c58-82df-cfbd8cede5f5" />

`LND`:

<img width="1206" height="784" alt="image" src="https://github.com/user-attachments/assets/8825fba1-211e-4116-9965-b6e5784819d1" />

`LBN`:

<img width="1197" height="712" alt="image" src="https://github.com/user-attachments/assets/2f050e70-dee5-4a36-8135-3c43a5e83987" />

`HKI`:

<img width="1197" height="712" alt="image" src="https://github.com/user-attachments/assets/bdab4c5a-c2e2-4f2b-b069-3bcba648ae2a" />

`MSC`:

<img width="1207" height="760" alt="image" src="https://github.com/user-attachments/assets/d0c0004e-e68a-4d88-99e3-ece61c12fb36" />

`SPB`:

<img width="1209" height="779" alt="image" src="https://github.com/user-attachments/assets/ebb90d7f-673f-4db1-8c00-a18903d10701" />

## 7. Пинг между PC1 и SGI_prism

`От SGI_prism -> PC1`:

<img width="885" height="586" alt="image" src="https://github.com/user-attachments/assets/c84d8e4d-2d39-43e2-995d-dd4446789dc5" />

Наоборот:

<img width="889" height="550" alt="image" src="https://github.com/user-attachments/assets/7e9062fc-6997-4b7b-9a26-db31b20ec896" />



