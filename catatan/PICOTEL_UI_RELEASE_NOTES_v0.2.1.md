# NetraOne Flutter Mobile v0.2.1 — Picotel UI Alignment

Tanggal: 20 Oktober 2026

## Baseline
- Flutter: NetraOne Mobile + Laravel v0.2.0 (versi yang sebelumnya diberikan).
- Referensi UI: `Desain.pptx` Picotel, 08 Oktober 2026, khususnya slide 3 (CCTV AI Mobile App) dan slide 2 (design system).
- Logo produk: `logo_netraone.png` final (dipakai pada login dan app bar), **bukan** contoh logo PICO di slide.

## Perubahan
- Material 3 theme: dark teal, teal, mint, putih, latar soft aqua; card, form, tombol, bottom navigation.
- Hero monitoring pada Dashboard dan akses cepat Home/Kamera/AI Event/Menu.
- Logo NetraOne final menggantikan logo JPEG lama pada komponen branding.
- Terminologi Edge -> High Computing untuk Platform Admin.
- High Computing disembunyikan dari menu, ringkasan dashboard, filter, subtitle, dan detail untuk member. Pengecekan izin API Laravel tetap wajib; pembatasan UI saja bukan security boundary.
- Operasi API, login, CRUD, event, notifikasi, profil, role dan permission dasar dipertahankan dari baseline.

## Catatan kesesuaian desain
- Slide desain memakai brand PICO sebagai contoh. NetraOne menggunakan logo produk final, sedangkan bahasa visual mengacu pada Picotel.
- `fontFamily: 'Poppins'` sudah disetel sebagai target; **berkas font Poppins tidak dibundel**. Untuk fidelity penuh, tim UI/UX harus menyediakan font berlisensi yang boleh dipakai dan menambahkan assets/fonts + deklarasi pubspec.yaml. Sampai itu dilakukan, Flutter memakai fallback sistem.
- Warna merupakan pendekatan berdasarkan visual PPT, perlu finalisasi nilai HEX oleh tim UI/UX.
- Screen spesifik Live View, Playback, Multi-Camera, PTZ tidak ditambahkan sebagai fitur baru karena memerlukan kontrak API/media yang tervalidasi. Screenshot PPT adalah referensi visual, bukan bukti backend telah mendukung fungsi tersebut.

## Deployment & UAT
1. Backup Flutter source v0.2.0; ganti folder Flutter dari ZIP ini (tidak perlu mengganti Laravel).
2. `flutter pub get`
3. `flutter analyze`
4. `flutter test`
5. `flutter run --dart-define=API_BASE_URL=https://netra-one.dgeo.id/api/v1`
6. Uji login Platform Admin, Admin Member, User Member; menu, dashboard, kamera, event, detail, profil, perubahan password, notifikasi, CRUD yang diizinkan, serta larangan High Computing bagi member.

## Validasi pengerjaan
- File source dan aset berhasil dibuat dan diperiksa keberadaannya.
- Flutter SDK/Dart analyzer tidak tersedia di lingkungan pengerjaan, sehingga **belum ada klaim analyze/build/test PASS**.
- Laravel backend tidak diubah.
