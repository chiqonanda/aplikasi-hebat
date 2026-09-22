# Menjalankan Aplikasi (preview)

## Reproduksi artefak build

1. `flutter pub get`
2. `flutter build web --no-pub` — menghasilkan `build/web/` (web build statis; `.env` di `assets/.env` ikut ter-bundle).

## Menjalankan server preview

Aplikasi web Flutter sudah di-build statis, jadi cukup HTTP server biasa:

```
python -m http.server 8931 --bind 127.0.0.1 --directory build/web
```

- Port 8931 (default preview thread ini).
- Log: `.freebuff/preview-471b1243-6418-4c94-90f5-8604554630ac.log` (stderr: `.log.err`).
- Setelah mengubah kode: jalankan ulang `flutter build web --no-pub`, lalu refresh browser (server tidak perlu direstart).
