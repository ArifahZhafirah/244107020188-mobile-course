# Deskripsi Pull Request

Judul: feat(notes): validasi judul kosong + test
Masalah: pengguna bisa menyimpan catatan tanpa judul.
Solusi: validasi di use case + pesan error di UI.
Cara uji: 1) tambah catatan kosong -> error muncul. 2) flutter test test/validate_note_test.dart
Closes #3

Screenshot:
- [Tempel screenshot pesan validasi judul kosong di sini]

## Catatan verifikasi

Kode yang tersedia memeriksa judul setelah `trim()`, sehingga judul kosong maupun yang hanya berisi spasi ditolak. Pesan validasinya ditampilkan oleh validator pada field judul. Tes use case mencakup judul kosong, judul whitespace, dan judul valid.

Saya tidak menjalankan `git diff` sesuai instruksi. Jalankan perintah berikut dari root repository untuk memastikan statistik branch terhadap target:

```powershell
git diff --stat develop...feat/notes-validation
```

Belum dapat dipastikan apakah total perubahan masih di bawah 300 baris sebelum output perintah tersebut diperiksa. Gunakan jumlah `insertions(+)` ditambah `deletions(-)` pada baris ringkasan sebagai total baris yang berubah; kirimkan outputnya untuk diperiksa.
