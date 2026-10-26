# NetraOne Mobile

Klien Flutter Android/iOS untuk alur MVP NetraOne. Aplikasi menggunakan Laravel
API yang sudah ada; backend tetap menjadi sumber otoritatif untuk autentikasi,
tenant, dan otorisasi.

## Prasyarat

- Flutter SDK yang memenuhi batas SDK di `pubspec.yaml`.
- Android Studio, Android SDK, dan emulator/perangkat untuk menjalankan Android.
- macOS dan Xcode untuk build/run iOS.
- URL API HTTPS dari tim backend atau lingkungan staging. Jangan gunakan URL
  produksi tanpa persetujuan tim.
- Akun uji yang disediakan khusus untuk lingkungan tersebut.

## Persiapan

Jalankan perintah dari direktori proyek:

```powershell
flutter pub get
flutter doctor
flutter doctor --android-licenses
flutter devices
```

Jika `flutter doctor --android-licenses` meminta persetujuan, tinjau dan terima
lisensi Android yang berlaku. Pastikan emulator aktif atau ponsel tersambung dan
terdeteksi oleh `flutter devices`.

## Troubleshooting Android

- Jika build berhasil tetapi aplikasi crash dengan
  `ClassNotFoundException: com.example.netraone_mobile.MainActivity`, pastikan
  plugin Kotlin Android diterapkan pada `android/app/build.gradle.kts` dan
  target JVM Java/Kotlin sama-sama 17. Konfigurasi proyek sudah menyetel
  keduanya.
- Jika `flutter run` melaporkan perangkat tidak ditemukan, sambungkan dan
  unlock perangkat, aktifkan USB debugging, setujui dialog otorisasi komputer,
  lalu pastikan perangkat muncul di `flutter devices`. APK yang berhasil dibuat
  tidak otomatis terpasang/dijalankan saat ADB kehilangan koneksi.
- Peringatan NDK menyebut versi NDK yang belum terpasang, tetapi berbeda dari
  crash `MainActivity`. Build saat ini memakai NDK yang tersedia dan tetap
  berhasil; instal versi yang direkomendasikan jika ingin menghilangkan warning.

## Menjalankan

URL API wajib diberikan saat run sebagai **origin backend saja**. Jangan
menambahkan `/api/v1` atau slash akhir; aplikasi menambahkan `/api/v1` secara
otomatis. Host production belum ditetapkan dalam spesifikasi, jadi ganti contoh
domain berikut dengan alamat yang diberikan tim backend:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-backend-domain
```

Untuk memilih target tertentu, lihat ID dari `flutter devices`, kemudian:

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=https://your-backend-domain
```

Sebagai contoh, konfigurasi `API_BASE_URL=https://backend.example.com` akan
mengirim request ke `https://backend.example.com/api/v1/mobile/login` dan
`https://backend.example.com/api/v1/events`. URL harus dapat dijangkau oleh
emulator/perangkat. `localhost` dari ponsel menunjuk ke ponsel itu sendiri;
untuk emulator Android, host development lokal biasanya diakses melalui
`10.0.2.2` (contoh: `http://10.0.2.2:8000`). HTTP hanya diizinkan untuk alamat
loopback/emulator lokal; gunakan HTTPS untuk server lain. Jangan menaruh token,
password, atau kredensial lain pada argumen run.

## Fitur MVP

- Login melalui `POST /mobile/login`; token disimpan memakai
  `flutter_secure_storage`.
- Pemulihan sesi melalui `GET /me`; logout memanggil
  `POST /mobile/logout` lalu menghapus token lokal.
- Bottom navigation untuk Beranda, Event, Kamera, dan Notifikasi.
- Daftar berpaginasi dengan pencarian, refresh, indikator memuat, keadaan
  kosong, serta pesan gagal dan coba lagi.
- Detail resource dimuat dari `GET /{resource}/{id}`.
- Penandaan notifikasi dibaca melalui `POST /notifications/{id}/read`.
- Tampilan detail menyaring field sensitif; media event tidak dimuat karena API
  belum menyediakan kontrak akses media yang aman.
- Profil hanya menampilkan identitas `GET /me`. Pengaturan profil/password,
  push notification, statistik agregat, dan pengelolaan media belum tersedia
  tanpa kontrak backend.

Semua path di atas relatif terhadap base path `/api/v1`. Respons `401` menghapus
sesi lokal; error lain termasuk `403`, `404`, `422`, `429`, dan `5xx` ditampilkan
sebagai kegagalan, bukan sebagai daftar kosong yang berhasil.

## Pemeriksaan

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=https://your-backend-domain
```

Uji pada emulator/perangkat Android dan simulator iOS sebelum rilis. Build iOS
memerlukan macOS/Xcode; build desktop bukan pengganti validasi Android/iOS.
