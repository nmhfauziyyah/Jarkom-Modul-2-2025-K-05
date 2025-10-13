# Di dalam Sirion (10.66.3.2) 
# Buat direktori dan file default untuk Sirion sendiri 

mkdir -p /var/www/html 
echo "<h1>Gerbang Sirion</h1><p>Selamat datang di reverse proxy K05.</p>" > /var/www/html/index.html 

# Buat file konfigurasi Nginx untuk reverse proxy 
# Perhatikan: Kita beri nama 'k05.conf' agar lebih relevan 

touch /etc/nginx/sites-available/k05.conf

# Di dalam Sirion, edit file /etc/nginx/sites-available/k05.conf 

nano /etc/nginx/sites-available/k05.conf
>>
server {
    listen 80;

    # Menerima permintaan untuk domain kanonikal dan nama host Sirion
    server_name www.k05.com sirion.k05.com;

    # Halaman default jika hanya mengakses domain utama
    location / {
        root /var/www/html;
        index index.html;
    }

    # Aturan #1: Routing untuk konten statis
    # Semua permintaan yang diawali dengan /static/ akan diteruskan ke Lindon
    location /static/ {
        # Meneruskan header penting ke backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Perintah kunci: teruskan permintaan ke server Lindon
        proxy_pass http://lindon.k05.com/;
    }

    # Aturan #2: Routing untuk konten dinamis
    # Semua permintaan yang diawali dengan /app/ akan diteruskan ke Vingilot
    location /app/ {
        # Meneruskan header penting ke backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Perintah kunci: teruskan permintaan ke server Vingilot
        proxy_pass http://vingilot.k05.com/;
    }
}

# Buat symbolic link untuk mengaktifkan situs 
ln -s /etc/nginx/sites-available/k05.conf /etc/nginx/sites-enabled/

# Hapus link default Nginx agar tidak terjadi konflik 
rm /etc/nginx/sites-enabled/default 

# Uji konfigurasi untuk memastikan tidak ada kesalahan sintaks 
nginx -t
service nginx restart

# Di klien (Earendil/Cirdan) 
curl http://www.k05.com/static/annals/ 

# >> output : <html>
<head><title>Index of /annals/</title></head>
<body>
<h1>Index of /annals/</h1><hr><pre><a href="../">../</a>
<a href="catatan_perjalanan.txt">catatan_perjalanan.txt</a>                             13-Oct-2025 12:33                   0
</pre><hr></body>
</html>
