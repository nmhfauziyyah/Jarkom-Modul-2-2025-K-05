# menghidupkan Vingilot sebagai server web dinamis menggunakan PHP
# in vingilot
apt-get update
apt-get install -y nginx php8.4-fpm

# Buat struktur folder
mkdir -p /var/www/app.K10.com/html

# Buat file beranda (index.php)
cat <<EOF > /var/www/app.K10.com/html/index.php
<?php
echo "<h1>Vingilot Mengarungi Dunia Digital</h1>";
echo "<p>Ini adalah beranda yang disajikan oleh PHP-FPM versi 8.4.</p>";
echo "<p><a href='/about'>Pelajari lebih lanjut tentang kami.</a></p>";
?>
EOF

# Buat file halaman 'about' (about.php)
cat <<EOF > /var/www/app.K10.com/html/about.php
<?php
echo "<h1>Tentang Vingilot</h1>";
echo "<p>Kami adalah kapal yang membawa cerita dinamis melintasi jaringan.</p>";
?>
EOF

# konfigurasi Nginx untuk PHP dan rewrite

cat <<EOF > /etc/nginx/sites-available/app.K05.com
server {
    listen 80;
    server_name app.K05.com;

    root /var/www/app.K05.com/html;
    index index.php;

    # Aturan rewrite: jika ada request ke /about, layani file /about.php
    rewrite ^/about$ /about.php last;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Teruskan request file PHP ke PHP-FPM 8.4
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # KOREKSI PENTING: Path ini sekarang cocok dengan versi yang diinstal
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
EOF

# aktifkan konfigurasi
ln -s /etc/nginx/sites-available/app.K05.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Verifikasi
# Cek konfigurasi Nginx
nginx -t

# Jika OK, restart kedua layanan
service nginx restart
service php8.4-fpm restart

# Verifikasi dari client (misal cirdan)
curl http://app.K05.com
curl http://app.K05.com/about.php
# penting
curl http://app.K05.com/about
