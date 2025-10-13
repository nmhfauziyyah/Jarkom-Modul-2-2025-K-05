#!/bin/bash
# Soal 4
# Zona Primer & Slave (k05.com)
# Tujuan: Mengatur zona DNS Master di Tirion dan Zona DNS Slave di Valmar.

# 4.1. Di Tirion (DNS Master: 10.66.3.3)
## Buat direktori zona
mkdir -p /etc/bind/K05

## Deklarasi Zona Options ; (sudah berada di /root/.bashrc)
nano /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    allow-query{any;};
    auth-nxdomain no;
    listen-on-v6 { any;
};

## Deklarasi Zona Master ; (sudah berada di /root/.bashrc)
nano /etc/bind/named.conf.local
zone "K05.com" {
    type master;
    notify yes; 
    also-notify { 10.66.3.4; }; 
    allow-transfer { 10.66.3.4; }; 
    file "/etc/bind/K05/db.K05.com";
};

## Konfigurasi File Zona Forward (Serial 01)
nano /etc/bind/K05/db.K05.com
$TTL    604800
@       IN      SOA     ns1.K05.com. root.K05.com. (
                        2025101301 ; Serial (Versi Awal)
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns1.K05.com.
@       IN      NS      ns2.K05.com.

; A Records
@       IN      A       10.66.3.2   ; Apex -> Sirion
ns1     IN      A       10.66.3.3   ; ns1.K05.com -> Tirion (Master)
ns2     IN      A       10.66.3.4   ; ns2.K05.com -> Valmar (Slave)

## Restart BIND9 // terapkan perubahan
service bind9 restart

# 4.2. Di Valmar (DNS Slave: 10.66.3.4)
## Deklarasi Zona Options ; (sudah berada di /root/.bashrc)
nano /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    allow-query{any;};
    auth-nxdomain no;
    listen-on-v6 { any;
};

## Deklarasi Zona Slave ; 
nano /etc/bind/named.conf.local
zone "K05.com" {
    type slave;
    masters { 10.66.3.3; }; 
    file "/var/cache/bind/db.K05.com";
};

## Restart BIND9 // terapkan perubahan
service bind9 restart

--
# Verifikasi query ke apex dan hostname layanan dalam zona dijawab melalui ns1/ns2.
# Misal di Earendil
ping K05.com -c 3
ping ns1.K05.com -c 3
ping ns2.K05.com -c 3



