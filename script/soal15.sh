# Di Elrond (10.66.2.3) 
apt  update && apt install -y apache2-utils

ab -n 500 -c 10 http://www.k05.com/app/
ab -n 500 -c 10 http://www.k05.com/static/

# Setelah setiap perintah ab selesai, Anda akan mendapatkan output yang detail. Metrik paling penting yang perlu diperhatikan adalah Requests per second.
# > endpoint statis (/static/) secara signifikan (~20x lebih cepat) daripada endpoint dinamis (/app/).
