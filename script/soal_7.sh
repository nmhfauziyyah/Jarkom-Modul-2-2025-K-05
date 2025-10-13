#!/bin/bash
# Soal 7
# A Records Layanan dan CNAMEs

## 7.1. Di Tirion (DNS Master: 10.66.3.3)
## Update Konfigurasi File Zona Forward (Serial 03)
nano /etc/bind/K05/db.K05.com || Ubah **Serial** menjadi `2025101303`
$TTL    604800
@       IN      SOA     ns1.K05.com. root.K05.com. (
                        2025101303 ; Serial (Naik dari 2)
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

; A Records Host Individu
eonwe           IN      A       10.66.3.1
sirion          IN      A       10.66.3.2
lindon          IN      A       10.66.3.5
vingilot        IN      A       10.66.3.6
earendil        IN      A       10.66.1.2
elwing          IN      A       10.66.1.3
cirdan          IN      A       10.66.2.2
elrond          IN      A       10.66.2.3
maglor          IN      A       10.66.2.4

#Add CNAME Records
; CNAME Records
www             IN      CNAME   sirion.K05.com.
static          IN      CNAME   lindon.K05.com.
app             IN      CNAME   vingilot.K05.com.
--

## Restart BIND9 // terapkan perubahan
service bind9 restart

# Verifikasi query ke apex dan hostname layanan dalam zona dijawab melalui ns1/ns2.
# Misal di Earendil
ping www.K05.com -c 3 # Seharusnya resolve ke 10.66.3.2
ping static.K05.com -c 3 # Seharusnya resolve ke 10.66.3.5
ping app.K05.com -c 3 # Seharusnya resolve ke 10.66.3.6