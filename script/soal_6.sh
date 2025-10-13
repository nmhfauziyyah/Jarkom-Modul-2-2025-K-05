#!/bin/bash
# Soal 6
# Verifikasi Zone Transfer

# Di Tirion (10.66.3.3)
dig @localhost K05.com SOA
# Output harus menunjukkan Serial: 2025101302

# Di Valmar (10.66.3.4)
dig @localhost K05.com SOA
# Output harus menunjukkan Serial: 2025101302
