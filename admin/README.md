# Admin

Folder ini berisi dashboard web admin Laravel.

## Fungsi

- Monitoring data aplikasi
- Pengelolaan konten admin
- Melihat ringkasan aktivitas dan voucher

## Cara Menjalankan

```bash
cd admin
composer install
npm install
copy .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

Jika ingin mode development frontend:

```bash
npm run dev
```

## Catatan

- Pastikan database dan environment sudah benar sebelum login ke dashboard
- Panduan lengkap ada di [README utama](../README.md)
