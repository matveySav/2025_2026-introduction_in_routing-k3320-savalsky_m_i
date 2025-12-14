# Report Lab4
- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2025/2026
- Group: K3320
- Author: Savalsky Matvey Ivanovich
- Lab: Lab4
- Date of create: 12.12.2025
- Date of finished:

# Часть 1

## 1. Схема лабы
В drawio нарисуем схему для 4-й лабы, определим адреса сетей и интерфейсов, mgmt сеть, loopback интерфейсы для роутеров, а также RR кластеры и адреса сетей vrf. Получим:

<img width="1202" height="651" alt="lab4_1 drawio" src="https://github.com/user-attachments/assets/425a80a7-020d-4e6e-8e17-fa0c31df2e66" />


## 2. Написание yml файла

Согласно вышеуказанной схеме напишем clab.yml файл:
```
name: lab4_1

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
      mgmt-ipv4: 172.20.20.2
      startup-config: configs/R1.NY.rsc
    R1.LND:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.3
      startup-config: configs/R1.LND.rsc
    R1.LBN:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.6
      startup-config: configs/R1.LBN.rsc
    R1.HKI:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.4
      startup-config: configs/R1.HKI.rsc
    R1.SPB:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.5
      startup-config: configs/R1.SPB.rsc
    R1.SVL:
      kind: vr-ros
      mgmt-ipv4: 172.20.20.7
      startup-config: configs/R1.SVL.rsc
    PC1:
      kind: linux
      mgmt-ipv4: 172.20.20.8
      exec:
        - ifconfig eth1 192.168.1.254 netmask 255.255.255.0
        - route add default gw 192.168.1.1 eth1
    PC2:
      kind: linux
      mgmt-ipv4: 172.20.20.9
      exec:
        - ifconfig eth1 192.168.2.254 netmask 255.255.255.0
        - route add default gw 192.168.2.1 eth1
    PC3:
      kind: linux
      mgmt-ipv4: 172.20.20.10
      exec:
        - ifconfig eth1 192.168.3.254 netmask 255.255.255.0
        - route add default gw 192.168.3.1 eth1
  links:
    - endpoints: ["PC1:eth1", "R1.NY:eth1"]
    - endpoints: ["R1.NY:eth2", "R1.LND:eth1"]
    - endpoints: ["R1.LND:eth2", "R1.HKI:eth1"]
    - endpoints: ["R1.LND:eth3", "R1.LBN:eth1"]
    - endpoints: ["R1.HKI:eth2", "R1.SPB:eth1"]
    - endpoints: ["R1.SPB:eth2", "PC2:eth1"]
    - endpoints: ["R1.HKI:eth3", "R1.LBN:eth2"]
    - endpoints: ["R1.LBN:eth3", "R1.SVL:eth2"]
    - endpoints: ["R1.SVL:eth1", "PC3:eth1"]
```

## 3. Конфиги для роутеров
Конфиги для роутеров NY,SPB и SVL аналогичны, как и для LND,HKI,LBN, поэтому объясню на одном из каждой группы.

Назначаем ip адреса на интерфейсы, создаем loopback и добавляем ему ip. </br>
Настраиваем ospf, задаем сети которые будем анонсировать (соседние внутренние + loopback). </br>
Настраиваем LDP, добавляеи интерфейсы, которые будует передавать MPLS трафик. </br>
Настраиваем BGP, добавляем соседа LND, прописываем update-source=lo (1.1.1.1) (тк на LND роутере NY роутер прописан как remote-peer=1.1.1.1), также  address-families=vpvn4, чтобы BGP анонсировал маршруты внутри VPN между другими VRF, где та же VPN. </br>
Создаем vrf instance, прописываем ей имя (routing-mark) это будет название таблицы маршрутизации для данной VRF, указываем RD и RT, поскольку у нас в условии одна VPN, то RD=RT_export=RT_import, указываем интерфейс, смотрящий на клиентскую сторону (куда подключен ПК1).</br>
Добавляем к BGP instance нашу VRF instance с routing-mark=devops и указываем redistribute-connected=yes, чтобы между VRF по BGP анонсировались маршруты напрямую подключенных к ним ПК.</br>
Меняем пользователя, пароль и имя устройства.

Для `R1_NY`:
```
/ip address
add address=9.1.0.1/30 interface=ether3
add address=192.168.1.1/24 interface=ether2

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
address-families=ip,vpnv4
/routing bgp network 
add network=9.1.0.0/30 

/ip route vrf add disabled=no routing-mark=devops route-distinguisher=1.1.1.1:100 \ 
export-route-targets=1.1.1.1:100 import-route-targets=1.1.1.1:100 interfaces=ether2
/routing bgp instance vrf add instance=default routing-mark=devops redistribute-connected=yes

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_New_York
```

Для роутеров LND,LBN,HKI аналогичная настройка,только не надо на них настраивать VRF. </br>
Также на этих роутерах указываем разные cluster-id (тк они являются RR сервером) и когда указываем BGP соседей, RR клиентам указываем route-reflect=yes.

Для `R1_LND`:
```
/ip address
add address=9.1.0.2/30 interface=ether2
add address=9.2.0.1/30 interface=ether3
add address=9.4.0.1/30 interface=ether4

/interface bridge add name=lo
/ip address add address=2.2.2.2/32 interface=lo

/routing ospf instance set default router-id=2.2.2.2
/routing ospf network 
add network=9.1.0.0/30 area=backbone
add network=9.2.0.0/30 area=backbone
add network=9.4.0.0/30 area=backbone
add network=2.2.2.2/32 area=backbone

/mpls ldp set enabled=yes lsr-id=2.2.2.2 transport-address=2.2.2.2
/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp instance set default as=65000 router-id=2.2.2.2 cluster-id=2.2.2.2
/routing bgp peer
add name=NY remote-address=1.1.1.1 remote-as=65000 route-reflect=yes update-source=lo \
address-families=ip,vpnv4
add name=LBN remote-address=5.5.5.5 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4
add name=HKI remote-address=3.3.3.3 remote-as=65000 route-reflect=no update-source=lo \
address-families=ip,vpnv4
/routing bgp network 
add network=9.1.0.0/30 
add network=9.4.0.0/30
add network=9.2.0.0/30

/user
add name=custom password=custom group=full
remove admin

/system identity set name=Router_London
```
## 4. Конфиги ПК
Всем ПК аналогично настраиваем статичный ip в выбранной в схеме в сети и указываем дефолтный шлюз на подключенный к ним роутер.
Для `PC1`:
```
ifconfig eth1 192.168.1.254 netmask 255.255.255.0
route add default gw 192.168.1.1 eth1
```

## 5. Таблицы маршрутизации на роутерах (и LFIB таблицы для меток MPLS) + BGP соседи и VRF
`NY`:

<img width="1417" height="982" alt="image" src="https://github.com/user-attachments/assets/cc87db2c-407f-4590-8d1b-6956d1c1b897" />
<img width="1833" height="398" alt="image" src="https://github.com/user-attachments/assets/a777e8f1-0f21-44b6-8a17-1a99621fbf24" />

`LND`:

<img width="1817" height="905" alt="image" src="https://github.com/user-attachments/assets/b93a23c4-71be-4bab-a441-b7e4ed5c2032" />

`LBN`:

<img width="1817" height="906" alt="image" src="https://github.com/user-attachments/assets/af1b6850-d8a1-420e-909e-cd466aa98d10" />

`HKI`:

<img width="1817" height="906" alt="image" src="https://github.com/user-attachments/assets/4740492d-8b31-4aab-95ad-d67cd6c4a484" />

`SVL`:

<img width="1833" height="929" alt="image" src="https://github.com/user-attachments/assets/ef222747-15c7-40aa-b63f-d2c62b1b38a3" />
<img width="1833" height="398" alt="image" src="https://github.com/user-attachments/assets/7533ce26-2552-402e-b449-c1da54005b25" />

`SPB`:

<img width="1817" height="906" alt="image" src="https://github.com/user-attachments/assets/104363bc-4a3f-4fdb-a8ca-b9e191b9bd24" />
<img width="1833" height="454" alt="image" src="https://github.com/user-attachments/assets/5bd4b4ac-e718-42d6-8391-4924bd2e260d" />

## 7. Пинг между ПК

От ПК1 к ПК2 и ПК3:

<img width="840" height="807" alt="image" src="https://github.com/user-attachments/assets/9770979c-9010-4dd8-bf33-87d4954de903" />


