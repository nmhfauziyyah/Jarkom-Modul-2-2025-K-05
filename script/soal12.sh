htpasswd -bc /etc/nginx/.htpasswd admin admin123

nano /etc/nginx/sites-available/k05.conf
>>server {
    listen 80;
    server_name www.k05.com sirion.k05.com;

    # Blok untuk menangani halaman utama, disajikan langsung oleh Sirion
    location / {
        root /var/www/html;
        index index.html;
    }

    # Blok keamanan untuk /admin/
    # Harus memberikan respons 401 jika tanpa kredensial
    location ^~ /admin/ {
        auth_basic "Restricted Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;

        # Respons jika autentikasi berhasil
        return 200 "<h1>Welcome, Admin! Access Granted.</h1>\n";
        root /var/www/html;
        index index.html;
    }

    # Blok reverse proxy untuk /static/ ke Lindon
    location /static/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://lindon.k05.com/;
    }

    # Blok reverse proxy untuk /app/ ke Vingilot
    location /app/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://vingilot.k05.com/;
    }
}

ln -sf /etc/nginx/sites-available/www.conf /etc/nginx/sites-enabled/www.conf
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

curl -i http://www.k05.com/admin/ 
# >> Output HTTP/1.1 401 Unauthorized
curl --user admin:admin123 http://www.k05.com/admin/ 
# >> Output: <h1>Welcome, Admin! Access Granted.</h1>
