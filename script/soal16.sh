# Menurunkan TTL
# Edit File Zona di Tirion

# Di Tirion (10.66.3.3)
nano /etc/bind/k05/db.k05.com

# Turunkan TTL dan Naikkan Serial Ubah TTL default di bagian atas file dan tambahkan TTL spesifik ke record lindon. Kemudian, naikkan nomor serial (misal dari ...03 ke ...04).
# DNS Zone file
; # Ubah TTL default menjadi 30 detik untuk eksperimen ini
$TTL    30
@       IN      SOA     ns1.k05.com. root.k05.com. (
                        2025101304 ; Serial (Naik dari 03)
                        ...
; ... record lain ...
; Beri TTL spesifik pada record lindon
lindon          IN      A       10.66.3.5
; ... record lain ...

Restart BIND di Tirion
# Di Tirion
service bind9 restart

# Verifikasi 3 moment

# Momen 1: Sebelum Perubahan IP
# Lakukan query pertama untuk mengisi cache DNS di klien.

# Di Earendil
# Instal dnsutils jika belum ada: apt-get install -y dnsutils
dig static.k05.com

# Hasil: Anda akan melihat static.k05.com diarahkan ke lindon.k05.com, yang kemudian mengarah ke alamat IP LAMA (10.66.3.5). Perhatikan angka di kolom kedua, itu adalah TTL yang tersisa (akan menjadi 30 atau sedikit di bawahnya).

# Eksekusi Perubahan IP di Tirion

# Di Tirion
nano /etc/bind/k05/db.k05.com

# Ubah IP dan Naikkan Serial Kita ubah oktet terakhir dari .5 menjadi .55 dan naikkan serial ke ...05.
DNS Zone file
$TTL    30
@       IN      SOA     ns1.k05.com. root.k05.com. (
                        2025101305 ; Serial (Naik dari 04)
                        ...
; ...
lindon          IN      A       10.66.3.55 ; <-- ALAMAT IP BARU
; …

# Di Tirion
service bind9 restart

# Momen 2: Sesaat Setelah Perubahan (Cache Masih Aktif)
# (dalam waktu kurang dari 30 detik) setelah me-restart BIND di Tirion, jalankan lagi perintah dig dari Earendil.

# Di Earendil
dig static.k05.com

# Momen 3: Setelah TTL Kedaluwarsa
# Sekarang, tunggu lebih dari 30 detik, lalu jalankan perintah dig untuk ketiga kalinya.

# Di Earendil
sleep 35 && dig static.k05.com

