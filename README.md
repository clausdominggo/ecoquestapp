# Capsetone Project

Panduan ini menjelaskan cara menjalankan seluruh bagian aplikasi di repository ini tanpa bingung. Struktur project terdiri dari 3 aplikasi terpisah:

- `backend/` = API utama Laravel untuk login, quest, voucher, dan progress user.
- `admin/` = dashboard web admin Laravel.
- `questapp/` = aplikasi mobile Flutter untuk visitor.

## Prasyarat

Pastikan tools berikut sudah terpasang:

- PHP 8.2+
- Composer
- Node.js 18+
- Flutter SDK 3.11+
- Database server yang dipakai Laravel kamu
- Android Emulator atau device fisik jika mau menjalankan aplikasi mobile

## Urutan Menjalankan Project

Jalankan komponen dengan urutan ini agar aplikasi mobile dan admin bisa terhubung ke backend dengan benar:

1. Jalankan `backend/` dulu.
2. Jalankan `admin/` jika ingin membuka dashboard web.
3. Jalankan `questapp/` terakhir untuk aplikasi mobile.

## 1. Backend API

Masuk ke folder backend:

```bash
cd backend
```

Install dependency jika belum ada:

```bash
composer install
npm install
```

Siapkan file environment:

```bash
copy .env.example .env
php artisan key:generate
```

Atur koneksi database di file `.env`, lalu jalankan migrasi dan seeder jika dibutuhkan:

```bash
php artisan migrate --seed
```

Jalankan backend:

```bash
php artisan serve
```

Jika ingin mode development lengkap:

```bash
npm run dev
```

Catatan:
- API default berjalan di `http://localhost:8000/api`
- Jika backend jalan di port atau host lain, sesuaikan URL API di mobile app

## 2. Admin Dashboard

Masuk ke folder admin:

```bash
cd admin
```

Install dependency:

```bash
composer install
npm install
```

Siapkan environment:

```bash
copy .env.example .env
php artisan key:generate
```

Atur koneksi database yang sama dengan backend jika memang dashboard memakai data yang sama, lalu jalankan:

```bash
php artisan migrate --seed
php artisan serve
```

Untuk development frontend:

```bash
npm run dev
```

## 3. Mobile App Flutter

Masuk ke folder mobile app:

```bash
cd questapp
```

Ambil dependency Flutter:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

### Setting API untuk mobile

- Jika pakai Android emulator, `localhost` biasanya bisa dipakai langsung.
- Jika pakai device fisik, buka menu `Settings` di aplikasi lalu isi custom API URL ke alamat backend yang bisa diakses dari device.
- Contoh:

```text
http://192.168.1.10:8000/api
```

## Cek Cepat Jika Aplikasi Tidak Jalan

- Pastikan backend aktif sebelum membuka mobile app.
- Pastikan URL API di mobile app mengarah ke backend yang benar.
- Pastikan database sudah dibuat dan migrasi sudah selesai.
- Jika login gagal, cek apakah user visitor sudah dibuat lewat seeder atau register.

## Fitur Utama

- Login/register visitor
- Peta quest dan detail quest
- Quest quiz, GPS, AR mock, plant ID mock, treasure hunt
- Result screen dan sync completion ke backend
- Leaderboard
- Voucher list, QR detail, review submit, redeem flow
- Profil user dengan progress, riwayat aktivitas, dan ringkasan voucher

## Catatan Tambahan

Folder `admin/` dan `backend/` sama-sama aplikasi Laravel, tetapi dipakai untuk tujuan berbeda. Jangan bingung kalau ada dua folder Laravel: satu untuk API utama dan satu untuk dashboard admin.
