# Lembar Peer Review — Praktikum 2

## Informasi PR

- Branch sumber: `feat/notes-validation`
- Target: `develop`
- Issue: #3
- Reviewer: Angel
- Tanggal review: 27 Oktober 2026

## Review untuk pasangan

**Kurang:** “Validasinya kurang bagus.”

**Baik:** “Observasi: `ValidateNote` mengembalikan error untuk judul kosong dan whitespace, tetapi belum ada widget test yang memastikan form menampilkan pesan dan tidak memanggil penyimpanan. Dampak: regresi pada sambungan validator ke UI dapat lolos dari test use case. Usulan: tambahkan widget test yang mengirim judul whitespace, memeriksa pesan error, dan memastikan aksi penyimpanan tidak berjalan.”

### Keputusan reviewer

- [x] Approve
- [ ] Request changes


## Self-review awal

**Batas pemeriksaan:** kode di salinan Minggu 8 yang tersedia saat ini dibaca langsung. `git diff develop...feat/notes-validation` tidak dijalankan sesuai instruksi, sehingga saya tidak dapat memastikan setiap catatan di bawah berada pada hunk PR atau membandingkannya dengan `develop`.

| Kategori | Observasi -> dampak -> usulan konkret | Bukti di kode |
| --- | --- | --- |
| Kebenaran — state/null | Observasi: tombol Simpan menghentikan aksi saat `formKey.currentState?.validate() ?? false` bernilai false, termasuk jika `currentState` null. Dampak: pada kondisi state form tidak tersedia, tombol tampak tidak merespons tanpa penjelasan. Usulan: pastikan form masih mounted sebelum aksi, dan bila kondisi null memang mungkin ditangani, beri umpan balik yang jelas alih-alih no-op diam-diam. | `week5_offline_notes/lib/pages/notes_page.dart`, guard sebelum `addNote` |
| Kebenaran — error path | Observasi: pemanggilan `addNote` di dalam callback async tidak menangani exception. Dampak: kegagalan database tidak ditampilkan sebagai pesan yang dapat ditindaklanjuti pengguna dan dapat menghasilkan error async yang tidak tertangani. Usulan: tangani kegagalan di lapisan aksi/repository sesuai pola error aplikasi, lalu tampilkan pesan UI tanpa menutup dialog seolah penyimpanan berhasil. | `week5_offline_notes/lib/pages/notes_page.dart`, callback tombol Simpan |
| Arsitektur | Observasi: route utama tetap menggunakan `NotesPage`, yang mengimpor model/repository pada `lib/data`, sementara `lib/features/notes/presentation/providers/notes_providers.dart` menyediakan jalur repository berbasis domain dan aksi feature-first. Use case `ValidateNote` dari feature domain juga diimpor langsung ke halaman lama. Dampak: dua alur notes hidup berdampingan sehingga tanggung jawab, DI, dan lokasi perubahan sulit ditentukan. Usulan: jadikan provider/aksi feature sebagai jalur UI utama dan migrasikan halaman secara bertahap; hindari menjadikan halaman lama konsumen langsung domain feature. | `week5_offline_notes/lib/main.dart`; `lib/pages/notes_page.dart`; `lib/features/notes/presentation/providers/notes_providers.dart` |
| Test | Observasi: `validate_note_test.dart` menguji use case untuk string kosong, whitespace, dan judul valid, tetapi tidak menguji integrasi validator dengan form atau perilaku tombol Simpan. Dampak: wiring UI dan pencegahan penyimpanan judul invalid belum terjaga oleh test. Usulan: tambahkan widget test yang memeriksa pesan pada field dan bahwa penyimpanan tidak dipanggil untuk input invalid. | `week5_offline_notes/test/validate_note_test.dart`; belum terlihat widget test terkait |
| Keterbacaan | Observasi: `notes_page.dart` menggabungkan relative import dan package import serta menyisakan beberapa blank line di antara import. Dampak: kelompok dependensi kurang mudah dipindai dan pola import sulit dijaga konsisten. Usulan: kelompokkan import sesuai konvensi proyek (Dart/Flutter, package, lalu relative) dan jalankan formatter/linter yang sudah dipakai proyek. | `week5_offline_notes/lib/pages/notes_page.dart`, bagian import |

### Keputusan self-review awal

**Request changes** — sebagai catatan awal untuk menindaklanjuti error path penyimpanan dan batas arsitektur. Ini bukan keputusan reviewer pasangan dan tidak menggantikan hasil `git diff` terhadap `develop`.

## Tindak lanjut

Belum ada komentar reviewer sejawat yang ditempel. Tabel berikut mencatat tindak lanjut self-review awal, bukan komentar pasangan.

| Komentar reviewer | Tindakan author | Status (selesai/ditolak + alasan) |
| --- | --- | --- |
| Kebenaran — state/null: form state null membuat Simpan berhenti tanpa pesan. | `_save` memeriksa `FormState` secara eksplisit; jika belum tersedia, memberi SnackBar dan tidak meneruskan penyimpanan. | Selesai — guard memberi umpan balik tanpa memanggil aksi simpan. |
| Kebenaran — error path: kegagalan simpan perlu ditangani tanpa menutup dialog atau membocorkan exception ke UI. | Simpan melalui `NotesActions`; kegagalan menampilkan pesan umum, mencatat detail diagnostik, dan mempertahankan dialog. | Selesai — kegagalan repository dan exception tidak ditampilkan mentah kepada pengguna. |
| Arsitektur: UI masih menggunakan provider/repository notes lama sementara provider feature-first tersedia. | Daftar, tambah, hapus, detail, dan `NoteTile` kini menggunakan provider/entity feature-first. Repository lama diberi provider khusus dan hanya dipakai untuk sinkronisasi. | Selesai sebagian — alur CRUD utama sudah feature-first; migrasi repository sinkronisasi tetap pekerjaan terpisah. |
| Test: belum ada widget test untuk jalur sukses dan kegagalan penyimpanan. | Tambah widget test untuk invalid tidak memanggil repository, valid memanggil repository, dan failure menampilkan pesan aman. | Selesai — ketiga jalur tersebut memiliki test widget. |
| Keterbacaan: import dan format kode belum konsisten. | Kelompokkan import yang disentuh dan jalankan formatter Dart pada `lib` serta `test`. | Selesai — `dart format --set-exit-if-changed lib test` melaporkan 22 file, 0 berubah. |

Untuk setiap baris, isi status dengan `Selesai — <perubahan yang dilakukan>` atau `Ditolak — <alasan teknis dan bukti>`. Setelah semua komentar ditangani:

1. **Request re-review:** balas tiap komentar dengan tindakan atau alasan penolakan, lalu minta reviewer memeriksa ulang melalui halaman PR GitHub. Dengan GitHub CLI, setelah mengganti placeholder:

   ```powershell
   gh pr edit <PR_NUMBER> --add-reviewer <GITHUB_USERNAME>
   ```

2. **Merge dengan squash:** setelah persetujuan dan pemeriksaan wajib PR lulus:

   ```powershell
   gh pr merge <PR_NUMBER> --squash
   ```

3. **Hapus branch setelah merge:** perintah merge di atas tidak menghapus branch sumber. Setelah memastikan PR sudah merged, hapus branch remote dan branch lokal:

   ```powershell
   git push origin --delete feat/notes-validation
   git branch -d feat/notes-validation
   ```

   Alternatifnya, saat merge gunakan `gh pr merge <PR_NUMBER> --squash --delete-branch` untuk meminta GitHub CLI menghapus branch sumber; dalam hal itu jangan ulangi penghapusan remote. Hapus branch lokal dengan `git branch -d feat/notes-validation` setelah memastikan branch sudah ter-merge.
