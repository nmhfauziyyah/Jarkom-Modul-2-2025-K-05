#!/bin/bash
# Soal 9
# Lindon (Web Statis dengan Autoindex)
# Tujuan: Mengatur Nginx di Lindon (`10.66.3.5`) untuk melayani `static.K05.com` dengan *directory listing* di `/annals/`.

# Buat Struktur Folder
mkdir -p /var/www/static.K05.com/html/annals
echo "<h1>Selamat Datang di Pelabuhan Statis Lindon</h1>" > /var/www/static.K05.com/html/index.html
touch /var/www/static.K05.com/html/annals/catatan_perjalanan.txt
touch /var/www/static.K05.com/html/annals/peta_beleriand.jpg

# Konfigurasi Nginx Server Block
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

# Aktifkan dan Restart Nginx
ln -s /etc/nginx/sites-available/static.K05.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

# Verifikasi
# Misal: Cirdan
# halaman utama
curl http://static.K05.com
# directory listening
curl http://static.K05.com/annals/

