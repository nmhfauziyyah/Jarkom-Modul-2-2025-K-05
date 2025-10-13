#!/bin/bash
# Soal 2
# Pastikan jalur WAN di router aktif dan NAT meneruskan trafik keluar bagi seluruh alamat internal sehingga host di dalam dapat mencapai layanan di luar menggunakan IP address.
> edit network configuration server (Eonwe)
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
        address 10.66.1.1
        netmask 255.255.255.0

auto eth2
iface eth2 inet static
        address 10.66.2.1
        netmask 255.255.255.0

auto eth3
iface eth3 inet static
        address 10.66.3.1
        netmask 255.255.255.0

> CONFIG CLI
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
apt install -y iptables
apt-get install -y bind9 dnsutils
apt-get install -y nginx apache2-utils
apt-get install -y nginx php8.4-fpm php-mysql 
apt-get install -y apache2-utils
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.66.0.0/16

---
# Soal 3
# Pastikan klien dapat saling berkomunikasi lintas jalur
> edit network configuration client
#Switch 1
- Earendil
auto eth0
iface eth0 inet static
        address 10.66.1.2
        netmask 255.255.255.0
        gateway 10.66.1.1

- Elwing
auto eth0
iface eth0 inet static
        address 10.66.1.3
        netmask 255.255.255.0
        gateway 10.66.1.1

#Switch 2
- Cirdan
auto eth0
iface eth0 inet static
        address 10.66.2.2
        netmask 255.255.255.0
        gateway 10.66.2.1

- Elrond
auto eth0
iface eth0 inet static
        address 10.66.2.3
        netmask 255.255.255.0
        gateway 10.66.2.1

- Maglor
auto eth0
iface eth0 inet static
        address 10.66.2.4
        netmask 255.255.255.0
        gateway 10.66.2.1

#Switch 3
- Sirion
auto eth0
iface eth0 inet static
        address 10.66.3.2
        netmask 255.255.255.0
        gateway 10.66.3.1

#Switch 4
- Tirion
auto eth0
iface eth0 inet static
        address 10.66.3.3
        netmask 255.255.255.0
        gateway 10.66.3.1

- Valmar
auto eth0
iface eth0 inet static
        address 10.66.3.4
        netmask 255.255.255.0
        gateway 10.66.3.1

- Lindon
auto eth0
iface eth0 inet static
        address 10.66.3.5
        netmask 255.255.255.0
        gateway 10.66.3.1

- Vingilot
auto eth0
iface eth0 inet static
        address 10.66.3.6
        netmask 255.255.255.0
        gateway 10.66.3.1

> CONFIG CLI (General Client)
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
# Tambahan :
- Tirion & Valmar (DNS Servers)
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
apt-get install -y bind9 dnsutils
ln -s /etc/init.d/named /etc/init.d/bind9

cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    allow-query{any;};
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

cat << EOF > /etc/bind/named.conf.local
zone "K05.com" {
    type master;
    notify yes; 
    also-notify { 10.66.3.4; }; 
    allow-transfer { 10.66.3.4; }; 
    file "/etc/bind/K05/db.K05.com";
};
EOF

- Lindon & Sirion (Nginx/web statis/proxy)
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
apt-get install -y nginx apache2-utils

- Vingilot
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
apt-get install -y nginx php8.4-fpm php-mysql 

- Elrond
cat << EOF > /etc/resolv.conf
Search K05.com
nameserver 10.66.3.3 # ns1.K05.com (Tirion) 
nameserver 10.66.3.4 # ns2.K05.com (Valmar) 
nameserver 192.168.122.1
EOF

apt update
apt-get install -y apache2-utils


