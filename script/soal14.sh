# Di dalam Vingilot (10.66.3.6) 
nano /etc/nginx/nginx.conf
http {
    # ... baris-baris lain ...

    log_format combined '$remote_addr - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent"';

    # TAMBAHKAN FORMAT BARU DI SINI
    log_format proxy '$http_x_real_ip - $remote_user [$time_local] '
                     '"$request" $status $body_bytes_sent '
                     '"$http_referer" "$http_user_agent"';

    # ... baris-baris lain ...
}

# Di dalam Vingilot (10.66.3.6) 
nano /etc/nginx/sites-available/app.K05.com
server {
    listen 80;
    server_name app.K05.com;

    # TAMBAHKAN BARIS INI UNTUK MENGGUNAKAN FORMAT LOG BARU
    access_log /var/log/nginx/app.k05.com_access.log proxy;

    root /var/www/app.K05.com/html;
    # ... sisa konfigurasi ...
}

nginx -t && service nginx restart

# Di Earendil 
curl http://www.k05.com/app/
# Di Vingilot 
tail /var/log/nginx/app.k05.com_access.log

# Log Lama : 10.66.3.2 - - [13/Oct/2025:21:43:00 +0700] "GET / HTTP/1.0" 200 ... (Mencatat IP Sirion)
# Log Baru : 10.66.1.2 - - [13/Oct/2025:21:43:00 +0700] "GET / HTTP/1.0" 200 ... (Mencatat IP Earendil, klien asli )