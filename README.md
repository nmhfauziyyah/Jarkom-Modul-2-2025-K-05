# Jarkom-Modul-2-2025-K-05
|No|Nama anggota|NRP|
|---|---|---|
|1. | Adiwidya Budi Pratama | 5027241012|
|2. | Ni'mah Fauziyyah Atok | 5027241103|
---
# Konfigurasi DNS dan Web Server (Soal 4–10)

Dokumentasi ini mencakup konfigurasi zona DNS (Master & Slave), reverse DNS, serta layanan web statis dan dinamis yang terkait dengan domain **K05.com**.

---

## 🧩 Soal 4 — Zona Primer & Slave (K05.com)

**Tujuan:** Mengatur zona DNS Master di **Tirion (10.66.3.3)** dan zona DNS Slave di **Valmar (10.66.3.4)**.

### 📍 Di Tirion (DNS Master)

1. Buat direktori zona:
   ```bash
   mkdir -p /etc/bind/K05
   ```

2. Konfigurasi `named.conf.options`:
   ```conf
   options {
       directory "/var/cache/bind";
       forwarders { 192.168.122.1; };
       dnssec-validation no;
       allow-query{any;};
       auth-nxdomain no;
       listen-on-v6 { any; };
   };
   ```

3. Deklarasi zona master di `/etc/bind/named.conf.local`:
   ```conf
   zone "K05.com" {
       type master;
       notify yes; 
       also-notify { 10.66.3.4; }; 
       allow-transfer { 10.66.3.4; }; 
       file "/etc/bind/K05/db.K05.com";
   };
   ```

4. Buat file zona:
   ```conf
   $TTL    604800
   @       IN      SOA     ns1.K05.com. root.K05.com. (
                           2025101301
                           604800
                           86400
                           2419200
                           604800 )
   @       IN      NS      ns1.K05.com.
   @       IN      NS      ns2.K05.com.
   @       IN      A       10.66.3.2
   ns1     IN      A       10.66.3.3
   ns2     IN      A       10.66.3.4
   ```

5. Restart layanan:
   ```bash
   service bind9 restart
   ```

---

### 📍 Di Valmar (DNS Slave)

1. Deklarasi zona slave di `/etc/bind/named.conf.local`:
   ```conf
   zone "K05.com" {
       type slave;
       masters { 10.66.3.3; }; 
       file "/var/cache/bind/db.K05.com";
   };
   ```

2. Restart layanan:
   ```bash
   service bind9 restart
   ```

---

## 🧾 Soal 5 & 6 — A Records & Verifikasi Sinkronisasi

### 📍 Di Tirion (Master)

1. Edit file zona dan tambahkan A Records host individu (Serial `2025101302`):
   ```conf
   ; A Records Host Individu
   eonwe   IN  A  10.66.3.1
   sirion  IN  A  10.66.3.2
   lindon  IN  A  10.66.3.5
   vingilot IN A 10.66.3.6
   earendil IN A 10.66.1.2
   elwing IN A 10.66.1.3
   cirdan IN A 10.66.2.2
   elrond IN A 10.66.2.3
   maglor IN A 10.66.2.4
   ```

2. Restart layanan:
   ```bash
   service bind9 restart
   ```

### 📍 Di Valmar (Slave)

1. Verifikasi serial dan data sinkron:
   ```bash
   dig @localhost K05.com SOA
   ```

2. Tes resolusi dari klien:
   ```bash
   ping lindon.K05.com -c 3
   ping earendil.K05.com -c 3
   ```

---

## 🌐 Soal 7 — CNAME Layanan

### 📍 Di Tirion

Tambahkan **CNAME records** (Serial `2025101303`) di file zona:
```conf
; CNAME Records
www      IN  CNAME  sirion.K05.com.
static   IN  CNAME  lindon.K05.com.
app      IN  CNAME  vingilot.K05.com.
megah    IN  CNAME  K05.com.
semangat IN  CNAME  K05.com.
```

Restart layanan:
```bash
service bind9 restart
```

### ✅ Verifikasi
```bash
ping www.K05.com -c 3
ping static.K05.com -c 3
ping app.K05.com -c 3
```

---

## 🔁 Soal 8 — Reverse DNS (PTR)

### 📍 Di Tirion (Master)

1. Deklarasi zona di `/etc/bind/named.conf.local`:
   ```conf
   zone "3.66.10.in-addr.arpa" {
       type master;
       notify yes;
       also-notify { 10.66.3.4; };
       allow-transfer { 10.66.3.4; };
       file "/etc/bind/K05/db.10.66.3";
   };
   ```

2. File `/etc/bind/K05/db.10.66.3`:
   ```conf
   $TTL    604800
   @ IN SOA ns1.K05.com. root.K05.com. (
              2025101301
              604800
              86400
              2419200
              604800 )
   @ IN NS ns1.K05.com.
   @ IN NS ns2.K05.com.

   1 IN PTR eonwe.K05.com.
   2 IN PTR sirion.K05.com.
   3 IN PTR tirion.K05.com.
   4 IN PTR valmar.K05.com.
   5 IN PTR lindon.K05.com.
   6 IN PTR vingilot.K05.com.
   ```

3. Restart BIND9:
   ```bash
   service bind9 restart
   ```

### 📍 Di Valmar (Slave)

```conf
zone "3.66.10.in-addr.arpa" {
    type slave;
    masters { 10.66.3.3; }; 
    file "/var/cache/bind/db.10.66.3";
};
```

Restart:
```bash
service bind9 restart
```

### ✅ Verifikasi
```bash
host 10.66.3.2
host 10.66.3.5
```

---

## 🪶 Soal 9 — Web Statis (Lindon)

### 📍 Di Lindon (10.66.3.5)

1. Instal Nginx:
   ```bash
   apt-get update
   apt-get install -y nginx
   ```

2. Struktur folder dan file:
   ```bash
   mkdir -p /var/www/static.K05.com/html/annals
   echo "<h1>Selamat Datang di Pelabuhan Statis Lindon</h1>" > /var/www/static.K05.com/html/index.html
   touch /var/www/static.K05.com/html/annals/catatan_perjalanan.txt
   ```

3. Konfigurasi virtual host:
   ```bash
   cat <<EOF > /etc/nginx/sites-available/static.K05.com
   server {
       listen 80;
       server_name static.K05.com;
       root /var/www/static.K05.com/html;
       index index.html;
       location / {
           try_files $uri $uri/ =404;
       }
       location /annals/ {
           autoindex on;
       }
   }
   EOF
   ```

4. Aktifkan konfigurasi:
   ```bash
   ln -s /etc/nginx/sites-available/static.K05.com /etc/nginx/sites-enabled/
   rm -f /etc/nginx/sites-enabled/default
   nginx -t
   service nginx restart
   ```

5. Verifikasi:
   ```bash
   curl http://static.K05.com/annals/
   ```

---

## ⚙️ Soal 10 — Web Dinamis (Vingilot)

### 📍 Di Vingilot (10.66.3.6)

1. Instal Nginx dan PHP-FPM:
   ```bash
   apt-get update
   apt-get install -y nginx php-fpm
   ```

2. Struktur folder dan file PHP:
   ```bash
   mkdir -p /var/www/app.K05.com/html
   cat <<EOF > /var/www/app.K05.com/html/index.php
   <?php
   echo "<h1>Vingilot Mengarungi Dunia Digital</h1>";
   echo "<p><a href='/about'>Pelajari lebih lanjut.</a></p>";
   ?>
   EOF

   cat <<EOF > /var/www/app.K05.com/html/about.php
   <?php
   echo "<h1>Tentang Vingilot</h1>";
   echo "<p>Kapal pembawa cerita dinamis.</p>";
   ?>
   EOF
   ```

3. Konfigurasi Nginx:
   ```bash
   cat <<EOF > /etc/nginx/sites-available/app.K05.com
   server {
       listen 80;
       server_name app.K05.com;
       root /var/www/app.K05.com/html;
       index index.php;
       rewrite ^/about$ /about.php last;
       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }
       location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php-fpm.sock;
       }
   }
   EOF
   ```

4. Aktifkan dan restart:
   ```bash
   ln -s /etc/nginx/sites-available/app.K05.com /etc/nginx/sites-enabled/
   rm -f /etc/nginx/sites-enabled/default
   nginx -t
   service nginx restart
   service php-fpm restart
   ```

5. Verifikasi:
   ```bash
   curl http://app.K05.com/about
   ```

---

📘 **Selesai.**
Seluruh konfigurasi DNS dan layanan web (statis & dinamis) untuk domain **K05.com** telah selesai dikonfigurasi dan dapat diuji dari sisi klien.

