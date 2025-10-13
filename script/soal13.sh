nano /etc/nginx/sites-available/k05.conf
# Tambahkan diatas : 

# BLOK SERVER 1: PENANGKAP & PENGALIH (REDIRECTOR)
# Blok ini akan menangani semua permintaan yang BUKAN 'www.k05.com'.
server {
    listen 80 default_server; # Menjadi server default untuk IP address
    server_name sirion.k05.com; # Juga menangani hostname alternatif

    # Perintah kunci:
    # Kembalikan kode 301 (Moved Permanently) ke nama kanonikal,
    # sambil mempertahankan path URL asli ($request_uri).
    return 301 http://www.k05.com$request_uri;
}

nginx -t && service nginx restart

# Uji Akses via IP Address (HARUS REDIRECT):
curl -iL http://10.66.3.2/static/annals/
# Output: HTTP/1.1 301 Moved Permanently di awal, diikuti oleh konten dari autoindex Lindon.

# Uji Akses via Hostname Alternatif (HARUS REDIRECT):
curl -iL http://sirion.k05.com/app/
# Output: HTTP/1.1 301 Moved Permanently di awal, diikuti oleh konten halaman PHP dari Vingilot.

# Uji Akses via Hostname Kanonikal (TIDAK BOLEH REDIRECT):
curl -i http://www.k05.com
# Output: HTTP/1.1 200 OK dan halaman sambutan Sirion, tanpa ada 301 redirect.
