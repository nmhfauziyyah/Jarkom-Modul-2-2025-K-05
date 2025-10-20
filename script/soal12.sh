# Di Sirion
htpasswd -bc /etc/nginx/.htpasswd admin admin123

nano /etc/nginx/sites-available/k05.conf
>># Di Sirion
# Tulis ulang file k05.conf dengan isi yang benar
cat << 'EOF' > /etc/nginx/sites-available/k05.conf
server {
    listen 80;
    server_name www.k05.com sirion.k05.com;

    # Blok untuk halaman utama
    location / {
        root /var/www/html;
        index index.html;
    }

    # Blok Normalisasi: Arahkan /admin -> /admin/
    location = /admin {
        return 301 /admin/;
    }

    # Blok Keamanan: Hanya /admin/ yang diamankan
    location ^~ /admin/ {
        auth_basic "Restricted Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        # HANYA 'return' setelah auth berhasil.
        return 200 "<h1>Welcome, Admin! Access Granted.</h1>\n";
    }

    # Blok reverse proxy ke Lindon
    location /static/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://lindon.k05.com/;
    }

    # Blok reverse proxy ke Vingilot
    location /app/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://vingilot.k05.com/;
    }
}
EOF

# 1. Hapus SEMUA link lama/salah di sites-enabled
rm -f /etc/nginx/sites-enabled/*

# 2. Buat link baru ke file YANG BENAR (k05.conf)
ln -s /etc/nginx/sites-available/k05.conf /etc/nginx/sites-enabled/k05.conf

# 3. Uji dan restart
nginx -t
# Harusnya 'syntax is ok' dan 'test is successful'
service nginx restart

curl -i http://www.k05.com/admin/ 
# >> Output HTTP/1.1 401 Unauthorized
curl --user admin:admin123 http://www.k05.com/admin/ 
# >> Output: <h1>Welcome, Admin! Access Granted.</h1>
