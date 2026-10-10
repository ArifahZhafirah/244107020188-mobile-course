# AI Challenge: Analisis Local Storage & Offline-First

**Prompt yang digunakan:**
> Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. Requirements: Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing. Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel. Tunjukkan skema tabel/kotak untuk 1000+ catatan. Jelaskan trade-off setiap pilihan.

---

## 1. Perbandingan Kriteria Storage

| Kriteria | SharedPreferences | Hive (NoSQL) | sqflite (SQLite) | Drift (SQLite ORM) |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat rendah (Hanya Key-Value). | Rendah (Filter/sorting manual di memory). | Sangat tinggi (Full SQL, aggregasi, limit/offset). | Sangat tinggi (Full SQL, query builder type-safe). |
| **Kebutuhan Relasi** | Tidak ada. | Terbatas (`HiveList`). | Sangat kuat (JOIN, Foreign Key). | Sangat kuat (JOIN, Foreign Key). |
| **Reaktivitas (Stream)** | Tidak ada (manual bungkus ke Stream). | Mendukung (`box.watch()`). | Tidak ada bawaan (hanya Future). | Sangat kuat (Bawaan `watch()` otomatis update). |
| **Type-safety** | Rendah (bisa *runtime error* salah tipe). | Tinggi (via *TypeAdapter* code-gen). | Rendah (Manual casting `Map<String, Object?>`). | Sangat tinggi (Compile-time checking). |
| **Ukuran Boilerplate** | Sangat rendah (Langsung pakai). | Sedang (Perlu `build_runner` untuk adapter). | Sedang (Tulis SQL & parser manual). | Sangat tinggi (Butuh banyak setup & code gen). |
| **Kemudahan Testing** | Sangat mudah (`setMockInitialValues`). | Sedang (Butuh setup path/mock box). | Mudah (Bisa *inject* in-memory `sqflite_ffi`). | Sangat mudah (Tersedia `NativeDatabase.memory()`). |

---

## 2. Rekomendasi Final & Alasan

Berikut adalah rekomendasi arsitektur penyimpanannya:

| Kebutuhan | Pilihan Teknologi | Alasan Keputusan |
| :--- | :--- | :--- |
| **Preferensi (Tema, Config)** | **SharedPreferences** | Preferensi aplikasi hanyalah data primitif (*boolean*, *string*) yang strukturnya sederhana (key-value). Menggunakan SQLite atau Drift untuk sekadar menyimpan status *dark mode* adalah *overkill* dan menambah kompleksitas yang tidak perlu. |
| **CRUD Catatan** | **sqflite (SQLite)** | Catatan bersifat terstruktur dan perlahan akan bertambah banyak. Memilih `sqflite` (dibanding Hive) memastikan kita bisa melakukan query berbasis `ORDER BY updated_at`, *pagination* jika dibutuhkan, dan memfilter data (`WHERE dirty = 1`) tanpa memuat semua objek ke memori. Dibandingkan *Drift*, `sqflite` dipilih karena *boilerplate*-nya tidak terlalu membebani untuk skala aplikasi yang baru memiliki 1-2 tabel saja (cocok untuk materi pembelajaran & *mini-project*). |

---

## 3. Skema Tabel untuk Skala 1000+ Catatan

Jika aplikasi menyimpan ribuan catatan (1000+ data), skema tabel relasional (seperti SQLite/sqflite) harus menggunakan **Indeks (INDEX)** untuk menjaga performa pencarian dan pengurutan (*sorting*). 

Berikut adalah skema `sqflite` yang dioptimalkan:

```sql
-- Tabel Utama
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Indeks Tambahan untuk Skalabilitas 1000+ Baris
-- Mempercepat query: SELECT * FROM notes ORDER BY updated_at DESC
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);

-- Mempercepat antrean sinkronisasi: SELECT COUNT(*) FROM notes WHERE dirty = 1
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

### Skema Alternatif menggunakan Hive (NoSQL)
Jika memaksakan penggunaan Hive, kita membuat *TypeAdapter*:
```dart
@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String body;
  @HiveField(3)
  DateTime updatedAt;
  @HiveField(4)
  bool dirty;
}
// Kendala 1000+ data di Hive: Box biasa akan me-load seluruh 1000 objek di memory saat dibuka. 
// Untuk efisiensi kita perlu menggunakan `LazyBox` dan melakukan iterasi/sorting secara manual di Dart.
```

---

## 4. Rangkuman Trade-off Setiap Pilihan

1. **SharedPreferences**: Cocok dan sangat cepat untuk preferensi sederhana, namun sangat buruk untuk menyimpan list JSON dalam jumlah besar (semua harus di-decode di memory, rawan rusak saat *partial update*).
2. **Hive**: Pilihan NoSQL yang sangat kencang dan reaktif untuk *local caching*. Trade-off utamanya adalah kesulitan melakukan *query* yang kompleks (seperti pagination dipadukan dengan filter multi-kolom).
3. **sqflite**: *Sweet spot* untuk data terstruktur. Terukur dengan baik hingga jutaan baris (dengan INDEX). Trade-off-nya adalah Anda kehilangan fitur reaktif (UI tidak otomatis update saat DB berubah) sehingga harus dipadukan secara manual dengan `Riverpod` (`ref.invalidate`).
4. **Drift**: Paket komplet paling aman (*type-safe*) dan reaktif, sangat direkomendasikan untuk aplikasi skala besar/enterprise. Trade-off utamanya adalah ukuran *learning curve*, banyaknya *boilerplate*, serta keharusan terus menjalankan `build_runner`.
