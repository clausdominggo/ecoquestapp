# questapp

Folder ini berisi aplikasi mobile Flutter untuk visitor.

## Fungsi

- Login/register visitor
- Main quest dari peta
- Quiz, GPS, AR mock, plant ID mock, treasure hunt
- Result screen, leaderboard, voucher, dan profil user

## Cara Menjalankan

```bash
cd questapp
flutter pub get
flutter run
```

## Setting API

- Jalankan backend dulu sebelum membuka app mobile
- Jika memakai device fisik, buka menu `Settings` di app lalu isi custom API URL ke alamat backend yang bisa diakses device
- Contoh:

```text
http://192.168.1.10:8000/api
```

## Catatan

- Emulator Android biasanya bisa memakai `localhost` lebih mudah
- Panduan lengkap ada di [README utama](../README.md)
