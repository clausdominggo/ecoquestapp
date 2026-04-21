# Backend

Folder ini berisi API utama Laravel untuk aplikasi Capsetone.

## Fungsi

- Auth login/register visitor
- Quest data dan quest completion
- Voucher list, review, dan redeem
- Sync progress user

## Cara Menjalankan

```bash
cd backend
composer install
npm install
copy .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

Jika ingin mode development:

```bash
npm run dev
```

## Catatan

- API default dipakai oleh aplikasi mobile di `questapp/`
- Jika kamu hanya ingin menjalankan mobile app, backend harus aktif dulu
- Panduan lengkap ada di [README utama](../README.md)
