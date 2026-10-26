# Struktur Flutter NetraOne

Kode aplikasi berada di `lib/` dan dipakai bersama oleh target Android serta iOS. Folder native `android/` dan `ios/` tetap menyimpan konfigurasi build, permission, ikon, dan integrasi khusus platform.

```text
lib/
├── app/                  # Root widget dan wiring aplikasi
├── core/
│   ├── models/           # Model ringan lintas fitur
│   ├── network/          # HTTP API, autentikasi, dan penyimpanan token
│   ├── theme/            # Token warna Picotel dan tema aplikasi
│   ├── utils/            # Formatter dan helper tampilan
│   └── shared.dart       # Export API, token, model, dan helper bersama
├── features/
│   ├── auth/presentation/
│   ├── dashboard/presentation/
│   ├── home/presentation/
│   ├── menu/presentation/
│   ├── profile/presentation/
│   └── resources/presentation/
├── shared/widgets/       # Widget visual yang dipakai lintas fitur
└── main.dart             # Entry point Flutter
```

Setiap fitur memiliki ruang sendiri agar layar dan alur fiturnya mudah ditemukan. Kode yang dipakai lintas fitur ditempatkan di `core/` atau `shared/`; jangan menambahkan kembali semua layar dan layanan ke `main.dart`. Fitur yang berkembang dapat menambahkan `data/` untuk repository/API khusus dan `domain/` untuk aturan bisnis tanpa mengubah pemisahan saat ini.

Tema memakai warna dari panduan UI Picotel dan nama keluarga font Poppins. Tambahkan berkas font Poppins ke `assets/fonts/` dan daftarkan melalui `pubspec.yaml` bila font harus konsisten pada semua perangkat; tanpa berkas font, Flutter memakai font fallback platform.

Jalankan aplikasi dengan konfigurasi target perangkat yang tersedia:

```sh
flutter run -d <android-device>
flutter run -d <ios-simulator-or-device>
```

Build iOS memerlukan macOS dan Xcode. Build Android memerlukan Android SDK.
