#!/bin/bash
# Soal 8
# Reverse DNS Zone (PTR Records)
# Tujuan: Mengatur zona DNS Reverse untuk segmen DMZ `10.66.3.x`.

# 8.1 Di Tirion (DNS Master: 10.66.3.3)
## Deklarasi Zona Master Reverse ; 
nano /etc/bind/named.conf.local
zone "K05.com" {
    type master;
    notify yes; 
    also-notify { 10.66.3.4; }; 
    allow-transfer { 10.66.3.4; }; 
    file "/etc/bind/K05/db.K05.com";
};

#Add Zona Reverse
zone "3.66.10.in-addr.arpa" {
    type master;
    notify yes;
    also-notify { 10.66.3.4; };
    allow-transfer { 10.66.3.4; };
    file "/etc/bind/K05/db.10.66.3";
};
--
## Konfigurasi File Zona Reverse (Serial 01)
nano /etc/bind/K05/db.10.66.3
$TTL    604800
@       IN      SOA     ns1.K05.com. root.K05.com. (
                        2025101301 ; Serial (Versi Awal)
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns1.K05.com.
@       IN      NS      ns2.K05.com.

; PTR Records (DMZ segment 10.66.3.x)
1       IN      PTR     eonwe.K05.com.
2       IN      PTR     sirion.K05.com.
3       IN      PTR     tirion.K05.com.
4       IN      PTR     valmar.K05.com.
5       IN      PTR     lindon.K05.com.
6       IN      PTR     vingilot.K05.com.

## Restart BIND9 // terapkan perubahan
service bind9 restart
--
# 8.2 Di Valmar (DNS Slave: 10.66.3.4)
# Deklarasi Zona Slave Reverse ; 
nano /etc/bind/named.conf.local
zone "K05.com" {
    type master;
    notify yes; 
    also-notify { 10.66.3.4; }; 
    allow-transfer { 10.66.3.4; }; 
    file "/etc/bind/K05/db.K05.com";
};

##Add Zona Sleve Reverse
zone "3.66.10.in-addr.arpa" {
    type slave;
    masters { 10.66.3.3; }; 
    file "/var/cache/bind/db.10.66.3";
};

## Restart BIND9 // terapkan perubahan
service bind9 restart
--
# Verifikasi 
# Misal di Earendil - Verifikasi PTR - Pastikan IP me-resolve ke hostname
host 10.66.3.2  # Output: sirion.K05.com.
host 10.66.3.5  # Output: lindon.K05.com.
