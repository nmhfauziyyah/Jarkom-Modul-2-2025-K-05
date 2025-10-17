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

## 🎈 Soal 10: Dynamic Web Server with PHP (Vingilot)

**Objective:** To configure `Vingilot` as a dynamic web server using Nginx and PHP-FPM, serving a site on `app.K05.com` with a URL rewrite for `/about`.

### Bash Script for Vingilot Setup

This script automates the installation of Nginx and PHP, creates the necessary web files, and configures the Nginx server block.

```bash
#!/bin/bash

# --- Installation ---
apt-get update
apt-get install -y nginx php8.4-fpm

# --- Directory and File Setup ---
# Create the web root directory
mkdir -p /var/www/app.K05.com/html

# Create the homepage (index.php)
cat <<EOF > /var/www/app.K05.com/html/index.php
<?php
echo "<h1>Vingilot Sails the Digital World</h1>";
echo "<p>This is the homepage served by PHP-FPM version 8.4.</p>";
echo "<p><a href='/about'>Learn more about us.</a></p>";
?>
EOF

# Create the 'about' page (about.php)
cat <<EOF > /var/www/app.K05.com/html/about.php
<?php
echo "<h1>About Vingilot</h1>";
echo "<p>We are the ship that carries dynamic stories across the network.</p>";
?>
EOF

# --- Nginx Configuration ---
cat <<EOF > /etc/nginx/sites-available/app.K05.com
server {
    listen 80;
    server_name app.K05.com;

    root /var/www/app.K05.com/html;
    index index.php;

    # Rewrite rule: serve /about.php for requests to /about
    rewrite ^/about$ /about.php last;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # Pass PHP scripts to the PHP-FPM service
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Ensure this path matches the installed PHP version
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
EOF

# --- Service Activation and Restart ---
# Enable the new site configuration
ln -s /etc/nginx/sites-available/app.K05.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test the Nginx configuration for errors
nginx -t

# Restart services to apply changes
service nginx restart
service php8.4-fpm restart

echo "Vingilot setup complete."
```

### Verification (from a client like Cirdan)

```bash
# Access the homepage
curl http://app.K05.com

# Access the about page via its direct filename
curl http://app.K05.com/about.php

# Access the about page via the clean URL (rewrite)
curl http://app.K05.com/about
```

-----

## 🚀 Soal 11: Reverse Proxy with Path-Based Routing (Sirion)

**Objective:** Configure `Sirion` as a reverse proxy that routes requests based on the URL path: `/static/*` goes to the `Lindon` server, and `/app/*` goes to the `Vingilot` server.

### Nginx Configuration for Sirion

```nginx
# /etc/nginx/sites-available/k05.conf

server {
    listen 80;
    server_name www.k05.com sirion.k05.com;

    # Default page served directly by Sirion
    location / {
        root /var/www/html;
        index index.html;
    }

    # Rule #1: Route static content requests to Lindon
    location /static/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://lindon.k05.com/;
    }

    # Rule #2: Route dynamic app requests to Vingilot
    location /app/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://vingilot.k05.com/;
    }
}
```

### Activation and Verification

```bash
# Enable the site
ln -s /etc/nginx/sites-available/k05.conf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test configuration and restart Nginx
nginx -t
service nginx restart

# Verify routing from a client
curl http://www.k05.com/static/annals/
curl http://www.k05.com/app/
```

-----

## φ(*￣0￣) Soal 12: Securing a Path with Basic Authentication (Sirion)

**Objective:** Protect the `/admin/` path on `Sirion` with username/password authentication.

### Setup

1.  **Create a password file:**

    ```bash
    # htpasswd -bc [file_path] [username] [password]
    htpasswd -bc /etc/nginx/.htpasswd admin admin123
    ```

2.  **Update Nginx Configuration:**
    Add a new `location` block for `/admin/` with authentication directives.

    ```nginx
    # /etc/nginx/sites-available/k05.conf (Updated)

    server {
        # ... other server settings ...

        # Secure location block for /admin/
        location ^~ /admin/ {
            auth_basic "Restricted Admin Area";
            auth_basic_user_file /etc/nginx/.htpasswd;

            # If authentication succeeds, return a welcome message
            return 200 "<h1>Welcome, Admin! Access Granted.</h1>\n";
        }

        # ... other location blocks (/static/, /app/) ...
    }
    ```

### Verification

```bash
# 1. Attempt access without credentials (should fail with 401 Unauthorized)
curl -i http://www.k05.com/admin/

# 2. Attempt access with correct credentials (should succeed)
curl --user admin:admin123 http://www.k05.com/admin/
```

-----

## (*/ω＼*) Soal 13: Canonical Hostname Redirection (Sirion)

**Objective:** Enforce `www.k05.com` as the canonical hostname by redirecting all requests made to Sirion's IP address or `sirion.k05.com`.

### Nginx Configuration Update

Add a new `server` block that catches non-canonical requests and issues a permanent (301) redirect.

```nginx
# /etc/nginx/sites-available/k05.conf (Updated)

# SERVER BLOCK 1: CATCH & REDIRECT
# Catches requests to the IP or alternative hostnames.
server {
    listen 80 default_server; # Becomes the default for the IP address
    server_name sirion.k05.com;

    # Permanently redirect to the canonical name, preserving the original URL path.
    return 301 http://www.k05.com$request_uri;
}

# SERVER BLOCK 2: CANONICAL HOST
# Handles requests for the main domain 'www.k05.com'.
server {
    listen 80;
    server_name www.k05.com;

    # ... all previous location blocks (/, /admin/, /static/, /app/) go here ...
}
```

### Verification

```bash
# Test IP address access (should redirect)
curl -iL http://10.66.3.2/static/annals/

# Test alternative hostname access (should redirect)
curl -iL http://sirion.k05.com/app/

# Test canonical hostname access (should NOT redirect)
curl -i http://www.k05.com
```

-----

## (‾◡◝) Soal 14: Logging Real Client IP on Backend (Vingilot)

**Objective:** Configure `Vingilot`'s access logs to record the original client's IP address passed by the `Sirion` reverse proxy, not Sirion's own IP.

### Setup on Vingilot

1.  **Define a new log format in `/etc/nginx/nginx.conf`:**

    ```nginx
    http {
        # ... other http settings ...

        # New log format that uses the X-Real-IP header
        log_format proxy '$http_x_real_ip - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent"';
    }
    ```

2.  **Apply the new format in the site configuration `/etc/nginx/sites-available/app.K05.com`:**

    ```nginx
    server {
        # ... server settings ...

        # Use the new 'proxy' log format
        access_log /var/log/nginx/app.k05.com_access.log proxy;

        # ... rest of the configuration ...
    }
    ```

### Verification

1.  From a client (`Earendil`), make a request:
    ```bash
    curl http://www.k05.com/app/
    ```
2.  On `Vingilot`, check the log file:
    ```bash
    tail /var/log/nginx/app.k05.com_access.log
    ```
      * **Before:** `10.66.3.2 - - ... "GET / HTTP/1.0" 200 ...` (Logs Sirion's IP)
      * **After:** `10.66.1.2 - - ... "GET / HTTP/1.0" 200 ...` (Logs Earendil's real IP)

-----

## ♦️ Soal 15: Load Testing with ApacheBench

**Objective:** Use ApacheBench (`ab`) to compare the performance of the static and dynamic endpoints.

### Setup and Execution (on client `Elrond`)

```bash
# Install Apache utilities
apt update && apt install -y apache2-utils

# Test the dynamic endpoint (/app/)
# -n 500: 500 total requests
# -c 10: 10 concurrent requests
ab -n 500 -c 10 http://www.k05.com/app/

# Test the static endpoint (/static/)
ab -n 500 -c 10 http://www.k05.com/static/
```

### Expected Result Summary

| Endpoint          | Relative Performance | Reason                                                 |
| ----------------- | -------------------- | ------------------------------------------------------ |
| **Dynamic (`/app/`)** | Slower               | Requires PHP processing and execution for every request. |
| **Static (`/static/`)** | Much Faster          | Nginx serves files directly from the disk without overhead. |

The static endpoint is expected to handle significantly more **requests per second**.

-----

## 🩻 Soal 16: DNS Record Change and TTL Propagation

**Objective:** Demonstrate how DNS changes propagate by lowering a record's TTL, changing its IP address, and observing the update from a client's perspective.

### Step 1: Lower TTL and Increment SOA Serial (on `Tirion`)

Edit the zone file `/etc/bind/k05/db.k05.com` to prepare for a quick change.

```dns
; Lower the default TTL for the experiment
$TTL    30
@       IN      SOA     ns1.k05.com. root.k05.com. (
                        2025101304 ; Serial (Incremented)
                        ...
);
...
; The record we plan to change
lindon          IN      A       10.66.3.5
...
```

### Step 2: Verification (Moment 1 - Before Change)

From a client (`Earendil`), query the record to cache the initial value.

```bash
# On Earendil
dig static.k05.com

# Expected Output: Shows the OLD IP (10.66.3.5) with a TTL near 30.
```

### Step 3: Execute IP Change (on `Tirion`)

Edit the zone file again, changing the IP address and incrementing the serial number.

```dns
$TTL    30
@       IN      SOA     ns1.k05.com. root.k05.com. (
                        2025101305 ; Serial (Incremented again)
                        ...
);
...
lindon          IN      A       10.66.3.55 ; <-- NEW IP ADDRESS
...
```

Then, restart BIND: `service bind9 restart`.

### Step 4: Verification (Moment 2 - Within TTL Window)

Immediately (within 30 seconds) query from the client again.

```bash
# On Earendil
dig static.k05.com

# Expected Output: STILL shows the OLD IP (10.66.3.5) because the client's DNS cache is still valid. The TTL will be lower than 30.
```

### Step 5: Verification (Moment 3 - After TTL Expires)

Wait for the TTL to expire (e.g., 35 seconds) and query one last time.

```bash
# On Earendil
sleep 35 && dig static.k05.com

# Expected Output: Now shows the NEW IP (10.66.3.55). The client's cache expired, forcing a new lookup to the authoritative server.
```
