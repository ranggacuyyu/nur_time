# NurTime — Aplikasi Pengingat Waktu Sholat & Tracker Ngaji

Disusun untuk memenuhi tugas **Asesmen Tengah Semester (ATS) Praktikum Pemrograman Perangkat Bergerak (RPL317)**.

- **Nama Mahasiswa**: Muhammad Rangga
- **NIM**: 4342501025
- **Tema Aplikasi**: Pengingat Waktu Sholat & Rutinitas Ngaji (Tilawah Al-Qur'an)
- **Framework**: Flutter (Dart)

---

## Pemenuhan Ketentuan Soal ATS

### 1. Arsitektur dan Halaman (8 Halaman/Screen)
1. **Splash Screen** (`lib/screens/splash_screen.dart`): Tampilan pembuka animasi logo islami, kutipan ayat Al-Qur'an, dan navigasi otomatis ke halaman Login.
2. **Login Screen** (`lib/screens/login_screen.dart`): Autentikasi pengguna dengan pilihan kota jadwal sholat dan tombol isi data demo otomatis.
3. **Dashboard / Beranda** (`lib/screens/dashboard_screen.dart`): Kartu hitung mundur (countdown real-time) menuju waktu sholat berikutnya, ringkasan progres tilawah & checklist ibadah, serta akses cepat.
4. **Jadwal & Pengingat Sholat** (`lib/screens/prayer_schedule_screen.dart`): Pengaturan kota (Batam, Jakarta, Bandung, Yogyakarta, Surabaya, Medan), toggle pengingat adzan per waktu sholat, mode notifikasi (Adzan/Getar/Senyap), uji pengingat adzan, dan simulasi error handling sinkronisasi offline.
5. **Pengingat & Tracker Ngaji** (`lib/screens/ngaji_tracker_screen.dart`): Progres target ayat harian, pengingat jadwal ngaji rutin (Ba'da Subuh, Ba'da Maghrib, Sebelum Tidur) dengan ubah jam (`TimePicker`), checklist target ibadah harian, form tambah catatan tilawah, serta riwayat tilawah.
6. **Detail Surah** (`lib/screens/surah_detail_screen.dart`): Menampilkan informasi surah, keutamaan, potongan ayat Arab beserta transliterasi & terjemahan, slider ukuran teks Arab, dan tombol *Tandai Sudah Dibaca Hari Ini*.
7. **Tasbih Digital & Doa Harian** (`lib/screens/dzikir_tasbih_screen.dart`): Counter tasbih interaktif dengan target (33/99/100), konfirmasi reset, dan daftar doa harian dengan pencarian dinamis.
8. **Profil & Pengaturan** (`lib/screens/profile_settings_screen.dart`): Edit nama tampilan, kota default, dan target ayat harian dengan validasi input serta dialog konfirmasi logout.

### 2. Manajemen State dan Lifecycle
- State aplikasi dikelola secara terpusat melalui `AppStateController` (`ChangeNotifier`) dan `AppStateScope` (`InheritedNotifier`) pada `lib/state/app_state.dart`.
- Tata letak menggunakan `NavigationBar` saat portrait dan otomatis beralih ke `NavigationRail` saat landscape (`MainShell` di `lib/screens/main_shell.dart`) menggunakan `IndexedStack`, sehingga data input, counter tasbih, log tilawah, dan timer tetap terjaga saat rotasi layar atau perpindahan halaman.
- Seluruh `Timer` dan `TextEditingController` dibersihkan melalui `dispose()` untuk mencegah memory leak.

### 3. Penanganan Error (Exception Handling) & Validasi
- **Validasi Form Login & Profil**: Menolak input kosong, panjang karakter tidak sesuai, dan batas angka target yang tidak wajar.
- **Validasi Input Catatan Ngaji**: Menolak jika ayat mulai < 1, ayat selesai < ayat mulai, atau melebihi jumlah maksimal ayat pada surah yang dipilih.
- **Exception Handling Jaringan**: Fitur sinkronisasi jadwal sholat dilengkapi blok `try-catch` dan simulasi mode offline yang menangkap `Exception` serta fallback ke jadwal lokal tanpa aplikasi force close.

---

## Cara Menjalankan Aplikasi
```bash
cd nur_time_app
flutter pub get
flutter run
```

## Pengujian Otomatis
```bash
flutter analyze
flutter test
```
