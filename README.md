# FlowMate (cima_mens) - Project Context & Documentation

Dokumen ini berisi rangkuman lengkap mengenai proyek aplikasi **FlowMate** (nama repositori: `cima_mens`). Dokumen ini disusun agar AI developer lain atau kolaborator dapat langsung memahami arsitektur, database, alur, serta fitur aplikasi ini.

---

## 📌 Deskripsi Umum
**FlowMate** adalah aplikasi mobile berbasis Flutter yang dirancang untuk melacak siklus menstruasi (menstruasi, masa subur, ovulasi) dan jurnal mood/gejala harian. Aplikasi ini memiliki keunikan berupa fitur **Partner Connection**, di mana seorang **Pemantau (Admin)** dapat terhubung dengan **Pelacak (Partner)** untuk memantau status siklus dan mood mereka secara real-time, serta mengirim pesan perhatian (nudges).

---

## 🛠️ Tech Stack & Dependensi
Aplikasi ini dikembangkan menggunakan teknologi berikut:

1. **Frontend**:
   - **Framework**: Flutter (Dart SDK `^3.10.4`)
   - **State Management**: `provider` (ChangeNotifier)
   - **Date & Calendar**: `table_calendar` (Kalender interaktif)
   - **Charts/Graphs**: `fl_chart` (Grafik riwayat siklus)
   - **Notification**: `flutter_local_notifications` & `timezone` (Notifikasi pengingat & pesan partner)
   - **Local Storage**: `shared_preferences` & `flutter_dotenv` (.env file loading)
   - **Data Sharing**: `share_plus` (Ekspor riwayat) & `csv` (Ekspor data format CSV)

2. **Backend & Database**:
   - **Supabase** (`supabase_flutter` SDK `^2.8.3`)
     - **Database**: PostgreSQL (Relational Database)
     - **Authentication**: Supabase Auth (Sign-in/Sign-up dengan custom user metadata)
     - **Realtime**: Supabase Realtime Channels (untuk auto-update notifikasi mood & pesan partner)
     - **Storage**: Supabase Storage (untuk upload foto profil & gambar mood)

---

## 🗄️ Arsitektur & Skema Database (Supabase)

Database di-host pada database PostgreSQL milik Supabase. Berikut adalah skema tabel-tabel utama yang digunakan oleh aplikasi:

### 1. Tabel `profiles`
Menyimpan data profil pengguna, baik pelacak (partner) maupun pemantau (admin).
* `id` (`uuid`, Primary Key, references `auth.users.id` cascade)
* `name` (`text`, nullable): Nama lengkap pengguna.
* `email` (`text`, nullable): Alamat email.
* `avatar_url` (`text`, nullable): Tautan foto profil di Supabase Storage.
* `role` (`text`, default: `'partner'`): Peran pengguna. Nilai yang didukung:
  * `'partner'` (Pelacak / Tracker): Melacak siklusnya sendiri.
  * `'admin'` (Pemantau / Monitor): Memantau siklus pasangannya.
* `partner_id` (`uuid`, nullable, references `profiles.id`): ID profil dari pasangan yang terhubung.
* `created_at` (`timestamp with time zone`)
* `updated_at` (`timestamp with time zone`)

### 2. Tabel `menstrual_cycles`
Menyimpan riwayat entri siklus menstruasi milik pengguna.
* `id` (`uuid`, Primary Key, default: `gen_random_uuid()`)
* `user_id` (`uuid`, references `profiles.id` cascade): Pemilik data siklus (harus memiliki role `'partner'`).
* `start_date` (`date`): Tanggal mulai menstruasi.
* `end_date` (`date`, nullable): Tanggal selesai menstruasi.
* `period_length` (`integer`, default: `5`): Durasi pendarahan dalam hari.
* `cycle_length` (`integer`, default: `28`): Panjang siklus rata-rata dalam hari.
* `notes` (`text`, nullable): Catatan tambahan.
* `created_at` (`timestamp with time zone`)
* `updated_at` (`timestamp with time zone`)

### 3. Tabel `moods`
Menyimpan catatan jurnal harian mengenai mood pengguna.
* `id` (`uuid`, Primary Key, default: `gen_random_uuid()`)
* `user_id` (`uuid`, references `profiles.id` cascade): Pemilik catatan mood.
* `image_mood_id` (`uuid`, references `image_moods.id` set null): Mengaitkan catatan ke icon/gambar mood tertentu.
* `note` (`text`, nullable): Catatan harian/curahan hati.
* `created_at` (`timestamp with time zone`)
* `updated_at` (`timestamp with time zone`)

### 4. Tabel `symptoms`
Menyimpan gejala fisik/mental yang dirasakan ketika membuat entri mood (Relasi Many-to-One ke tabel `moods`).
* `id` (`bigint`, Primary Key, Generated Always as Identity)
* `mood_id` (`uuid`, references `moods.id` cascade): Menghubungkan gejala ke log mood terkait.
* `symptom` (`text`): Nama gejala (contoh: `'kram'`, `'sakit kepala'`, `'lelah'`, `'kembung'`, dll).

### 5. Tabel `image_moods`
Menyimpan katalog mood/emosi beserta icon/gambarnya.
* `id` (`uuid`, Primary Key, default: `gen_random_uuid()`)
* `name` (`text`): Nama emosi/mood (contoh: `'Senang'`, `'Sedih'`, `'Marah'`, `'Cemas'`, dll).
* `image_url` (`text`): URL asset icon mood.

### 6. Tabel `partner_messages`
Menyimpan pesan/nudges yang dikirim antar pasangan terhubung.
* `id` (`uuid`, Primary Key, default: `gen_random_uuid()`)
* `sender_id` (`uuid`, references `profiles.id` cascade): ID pengirim pesan.
* `receiver_id` (`uuid`, references `profiles.id` cascade): ID penerima pesan.
* `message` (`text`): Isi pesan/nudge perhatian.
* `created_at` (`timestamp with time zone`)

---

## 🔄 Alur & Logika Bisnis Utama

### 1. Pendaftaran & Autentikasi (`AuthService`)
* Pengguna mendaftar dengan memilih **Tipe Akun**:
  * **Pelacak (Tracker)** $\rightarrow$ role database: `'partner'`.
  * **Pemantau (Monitor)** $\rightarrow$ role database: `'admin'`.
* Data profil disimpan otomatis di tabel `profiles` via pemicu Supabase Auth (atau pendaftaran manual).

### 2. Hubungan Antar Pasangan (Connection)
* Dua pengguna dapat terhubung dengan memperbarui kolom `partner_id` pada tabel `profiles` dengan ID satu sama lain.
* Setelah terhubung, data siklus menstruasi dan entri mood pelacak dapat diakses oleh pemantau.

### 3. Perhitungan Fase Siklus (`CycleCalculator`)
Kalkulator siklus menggunakan rumus murni berbasis tanggal:
* **Hari Pertama Siklus (Day 1)**: `start_date`
* **Prediksi Datang Bulan Berikutnya**: `startDate + cycleLength`
* **Hari Ovulasi**: `startDate + (cycleLength - 14)`
* **Jendela Masa Subur (Fertile Window)**: `ovulation - 5 hari` sampai `ovulation + 1 hari`.
* **Fase Siklus yang Ditentukan**:
  1. `menstruasi`: Hari ke-1 s.d `period_length`.
  2. `folikular`: Setelah selesai menstruasi s.d sebelum jendela subur.
  3. `ovulasi` (Masa Subur): Rentang hari jendela masa subur.
  4. `luteal`: Setelah masa subur berakhir s.d sebelum hari menstruasi berikutnya.

### 4. Real-time Subscription (`RealtimeService`)
Aplikasi mendengarkan perubahan real-time pada:
* Tabel `moods`: Ketika Pelacak menambahkan mood baru, Pemantau mendapatkan notifikasi push/lokal: *"Partner Anda menambahkan mood baru: [Nama Mood]"*.
* Tabel `partner_messages`: Ketika Pemantau mengirim pesan ke Pelacak, Pelacak menerima notifikasi push/lokal: *"Pesan dari Partner 💌: [Isi Pesan]"*.

---

## 🎨 Struktur Folder Kode Program
```text
lib/
├── main.dart             # Titik awal aplikasi, inisialisasi Supabase & Provider
├── models/
│   ├── app_settings.dart  # Konfigurasi app (warna tema, onboarding, notifikasi)
│   ├── cycle_model.dart   # Representasi data siklus menstruasi
│   ├── mood_model.dart    # Representasi jurnal mood & gejala harian
│   └── profile_model.dart # Representasi profil pengguna & role
├── providers/
│   ├── auth_provider.dart     # State manajemen autentikasi & profil
│   ├── cycle_provider.dart    # State manajemen riwayat siklus & perhitungan fase
│   ├── mood_provider.dart     # State manajemen riwayat mood & gejala
│   └── settings_provider.dart # State manajemen pengaturan visual & notifikasi
├── services/
│   ├── auth_service.dart          # Integrasi ke Supabase Auth
│   ├── cycle_calculator.dart      # Utilitas kalkulasi siklus & masa subur (pure functions)
│   ├── notification_service.dart  # Inisialisasi & pemanggilan local notifications
│   ├── realtime_service.dart      # Subscription realtime ke database
│   └── supabase_service.dart      # Query database CRUD (cycles, moods, partner messages)
├── utils/
│   ├── date_utils.dart  # Formatting tanggal & waktu
│   └── theme.dart       # Pengaturan tema visual dinamis
├── widgets/             # Widget-widget reusable (custom button, card, dll)
└── screens/
    ├── onboarding_screen.dart    # Onboarding setup awal
    ├── settings_screen.dart      # Pengaturan tema & reset data
    ├── auth/
    │   ├── splash_screen.dart    # Splash screen inisial
    │   ├── login_screen.dart     # Layar masuk pengguna
    │   └── register_screen.dart  # Layar pendaftaran pengguna (memilih tipe akun)
    ├── profile/
    │   └── profile_screen.dart   # Pengaturan koneksi partner & detail akun
    ├── admin/
    │   └── admin_dashboard.dart  # Dashboard khusus pemantau (melihat mood & mengirim nudge)
    // Layar khusus Pelacak (role 'partner')
    ├── calendar_screen.dart      # Kalender interaktif & ringkasan fase
    ├── cycle_graph_screen.dart   # Grafik panjang siklus & statistik
    ├── history_screen.dart       # Riwayat detail log menstruasi & ekspor data
    └── mood_screen.dart          # Pencatatan mood, gejala fisik, & note harian
```

---

## 🔑 Konfigurasi Environment (`.env`)
Aplikasi memerlukan file `.env` di root proyek yang berisi:
```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key-here>
```
File ini harus didaftarkan di bagian `assets` pada `pubspec.yaml` agar dapat dibaca saat runtime oleh `flutter_dotenv`.
