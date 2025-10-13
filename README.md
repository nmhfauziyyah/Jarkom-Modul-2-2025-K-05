# Jarkom-Modul-2-2025-K-05

---

## 1. Soal 4: Zona Primer & Slave (K05.com)

Tujuan: Mengatur zona DNS Master di Tirion dan Zona DNS Slave di Valmar.

### 1.1. Di Tirion (DNS Master: 10.66.3.3)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Buat direktori zona (penting: K05 kapital)** | ```bash
mkdir -p /etc/bind/K05
``` |
| **2.** | **Konfigurasi `named.conf.options`** | Tambahkan forwarder. |
| | `nano /etc/bind/named.conf.options` | Pastikan isinya: |
| | ```conf
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation no;
    allow-query{any;};
    auth-nxdomain no;
    listen-on-v6 { any; };
};
``` | |
| **3.** | **Deklarasi Zona Master** | Tambahkan deklarasi zona di `/etc/bind/named.conf.local`. |
| | `nano /etc/bind/named.conf.local` | Tambahkan: |
| | ```conf
zone "K05.com" {
    type master;
    notify yes; 
    also-notify { 10.66.3.4; }; 
    allow-transfer { 10.66.3.4; }; 
    file "/etc/bind/K05/db.K05.com";
};
``` | **Path file menggunakan K05 kapital.** |
| **4.** | **Konfigurasi File Zona Forward (Serial 01)** | Buat dan isi file zona `/etc/bind/K05/db.K05.com`. |
| | `nano /etc/bind/K05/db.K05.com` | Serial Awal: `2025101301` |
| | ```conf
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
``` | |
| **5.** | **Restart BIND9** | Terapkan perubahan. |
| | ```bash
service bind9 restart
``` | |

### 1.2. Di Valmar (DNS Slave: 10.66.3.4)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Konfigurasi `named.conf.options`** | Sama seperti Tirion. |
| | *Pastikan `/etc/bind/named.conf.options` sudah diisi forwarder.* | |
| **2.** | **Deklarasi Zona Slave** | Tambahkan deklarasi zona di `/etc/bind/named.conf.local`. |
| | `nano /etc/bind/named.conf.local` | Tambahkan: |
| | ```conf
zone "K05.com" {
    type slave;
    masters { 10.66.3.3; }; 
    file "/var/cache/bind/db.K05.com";
};
``` | Slave menyimpan file di folder cache. |
| **3.** | **Restart BIND9** | BIND9 akan memulai Zone Transfer. |
| | ```bash
service bind9 restart
``` | |

---

## 2. Soal 5 & 6: Penamaan Host dan Verifikasi

Tujuan: Menambahkan A Records untuk semua host individu dan memverifikasi sinkronisasi Slave.

### 2.1. Di Tirion (DNS Master: 10.66.3.3)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Update File Zona Forward (Serial 02)** | Naikkan Serial dan tambahkan A Records untuk semua host. |
| | `nano /etc/bind/K05/db.K05.com` | Ubah **Serial** menjadi `2025101302`. |
| | **Tambahkan A Records ini di bawah `ns2`:** |
| | ```conf
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
``` | |
| **2.** | **Restart BIND9** | Terapkan perubahan. |
| | ```bash
service bind9 restart
``` | |

### 2.2. Verifikasi Zone Transfer (Soal 6) - Di Valmar (10.66.3.4)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Cek Serial di Slave** | Pastikan serial sudah naik. |
| | ```bash
dig @localhost K05.com SOA
# Output harus menunjukkan Serial: 2025101302
``` | |
| **2.** | **Cek Resolusi dari Klien** | Pastikan A Records Host Baru ter-resolve (mis. di Earendil). |
| | ```bash
ping lindon.K05.com -c 3
ping earendil.K05.com -c 3
``` | |

---

## 3. Soal 7: A Records Layanan dan CNAMEs

Tujuan: Menambahkan alias (CNAME) untuk layanan web.

### 3.1. Di Tirion (DNS Master: 10.66.3.3)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Update File Zona Forward (Serial 03)** | Naikkan Serial dan tambahkan CNAME Records. |
| | `nano /etc/bind/K05/db.K05.com` | Ubah **Serial** menjadi `2025101303`. |
| | **Tambahkan CNAME Records ini di bagian bawah:** |
| | ```conf
; CNAME Records
www             IN      CNAME   sirion.K05.com.
static          IN      CNAME   lindon.K05.com.
app             IN      CNAME   vingilot.K05.com.
megah           IN      CNAME   K05.com.
semangat        IN      CNAME   K05.com.
``` | |
| **2.** | **Restart BIND9** | Terapkan perubahan. |
| | ```bash
service bind9 restart
``` | |

### 3.2. Verifikasi CNAMEs - Di Klien (mis. Earendil)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Verifikasi Resolusi CNAME** | Pastikan alias mengarah ke host yang benar. |
| | ```bash
ping www.K05.com -c 3     # Seharusnya resolve ke 10.66.3.2
ping static.K05.com -c 3  # Seharusnya resolve ke 10.66.3.5
ping app.K05.com -c 3     # Seharusnya resolve ke 10.66.3.6
``` | |

---

## 4. Soal 8: Reverse DNS Zone (PTR Records)

Tujuan: Mengatur zona DNS Reverse untuk segmen DMZ `10.66.3.x`.

### 4.1. Di Tirion (DNS Master: 10.66.3.3)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Deklarasi Zona Reverse** | Tambahkan di `/etc/bind/named.conf.local`. |
| | `nano /etc/bind/named.conf.local` | Tambahkan: |
| | ```conf
zone "3.66.10.in-addr.arpa" {
    type master;
    notify yes;
    also-notify { 10.66.3.4; };
    allow-transfer { 10.66.3.4; };
    file "/etc/bind/K05/db.10.66.3";
};
``` | |
| **2.** | **Konfigurasi File Zona Reverse (Serial 01)** | Buat file `/etc/bind/K05/db.10.66.3`. |
| | `nano /etc/bind/K05/db.10.66.3` | Isi lengkap: |
| | ```conf
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
``` | |
| **3.** | **Restart BIND9** | Terapkan perubahan. |
| | ```bash
service bind9 restart
``` | |

### 4.2. Di Valmar (DNS Slave: 10.66.3.4)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Deklarasi Zona Slave Reverse** | Tambahkan di `/etc/bind/named.conf.local`. |
| | `nano /etc/bind/named.conf.local` | Tambahkan: |
| | ```conf
zone "3.66.10.in-addr.arpa" {
    type slave;
    masters { 10.66.3.3; }; 
    file "/var/cache/bind/db.10.66.3";
};
``` | |
| **2.** | **Restart BIND9** | Memulai Zone Transfer Reverse. |
| | ```bash
service bind9 restart
``` | |

### 4.3. Verifikasi Reverse DNS - Di Klien (mis. Earendil)

| Langkah | Skrip / Perintah | Keterangan |
| :--- | :--- | :--- |
| **1.** | **Instal DNS Utils** | Dibutuhkan untuk perintah `host` atau `dig`. |
| | ```bash
apt-get install dnsutils
``` | |
| **2.** | **Verifikasi PTR** | Pastikan IP me-resolve ke hostname. |
| | ```bash
host 10.66.3.2  # Output: sirion.K05.com.
host 10.66.3.5  # Output: lindon.K05.com.
``` | |

---

## 5. Soal 9: Lindon (Web Statis dengan Autoindex)

Tujuan: Mengatur Nginx di Lindon (`10.66.3.5`) untuk melayani `static.K05.com` dengan *directory listing* di `/annals/`.

| Host | Langkah | Skrip / Perintah |
| :--- | :--- | :--- |
| **Lindon** | **1. Instal Nginx** | ```bash
apt-get update
apt-get install -y nginx
``` |
| | **2. Buat Struktur Folder** | ```bash
mkdir -p /var/www/static.K05.com/html/annals
echo "<h1>Selamat Datang di Pelabuhan Statis Lindon</h1>" > /var/www/static.K05.com/html/index.html
touch /var/www/static.K05.com/html/annals/catatan_perjalanan.txt
``` |
| | **3. Konfigurasi Nginx Server Block** | ```bash
cat <<EOF > /etc/nginx/sites-available/static.K05.com
server {
    listen 80;
    server_name static.K05.com;
    root /var/www/static.K05.com/html;
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location /annals/ {
        autoindex on; # AKTIFKAN DIRECTORY LISTING
    }
}
EOF
``` |
| | **4. Aktifkan dan Restart Nginx** | ```bash
ln -s /etc/nginx/sites-available/static.K05.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart
``` |
| **Klien** | **5. Verifikasi** | ```bash
curl http://static.K05.com/annals/
``` |

---

## 6. Soal 10: Vingilot (Web Dinamis dengan PHP-FPM dan Rewrite)

Tujuan: Mengatur Nginx dan PHP-FPM di Vingilot (`10.66.3.6`) untuk melayani `app.K05.com` dengan *URL rewriting*.

| Host | Langkah | Skrip / Perintah |
| :--- | :--- | :--- |
| **Vingilot** | **1. Instal Nginx & PHP-FPM** | ```bash
apt-get update
# Asumsi PHP versi terbaru yang tersedia (misal php-fpm)
apt-get install -y nginx php-fpm
``` |
| | **2. Buat Struktur Folder & File PHP** | ```bash
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
``` |
| | **3. Konfigurasi Nginx Server Block** | **Perhatikan: `fastcgi_pass` mungkin perlu disesuaikan dengan versi PHP.** |
| | ```bash
cat <<EOF > /etc/nginx/sites-available/app.K05.com
server {
    listen 80;
    server_name app.K05.com;
    root /var/www/app.K05.com/html;
    index index.php;
    # Aturan rewrite
    rewrite ^/about$ /about.php last; 
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    # Teruskan request PHP ke FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }
}
EOF
``` | |
| | **4. Aktifkan dan Restart Layanan** | ```bash
ln -s /etc/nginx/sites-available/app.K05.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart
service php-fpm restart
``` |
| **Klien** | **5. Verifikasi Rewrite** | ```bash
curl http://app.K05.com/about 
# Output harus menampilkan isi dari about.php
``` |
