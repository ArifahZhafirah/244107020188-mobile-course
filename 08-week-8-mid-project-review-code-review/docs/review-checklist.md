# Review Checklist Minggu 8

## Audit Git

Audit dilakukan pada 25 Oktober 2026 di branch `feat/notes-validation`, sebelum perubahan praktikum ini. Worktree bersih. Riwayat yang diperiksa berisi 16 commit; commit terbaru adalah `ba29434 Revise README for Clean Architecture project`.

| Pemeriksaan | Temuan |
| --- | --- |
| Commit langsung ke `main` | Riwayat memuat 16 commit yang juga ada pada `main`. `git log --oneline` tidak membuktikan apakah setiap perubahan masuk lewat Pull Request atau commit langsung. |
| Pesan commit kurang spesifik | `Praktikum 7 done`, `Update README.md`, dan `Add files via upload` tidak menjelaskan perubahan secara memadai. |
| Branch fitur lebih dari satu minggu | Tidak dapat ditentukan dari ringkasan log; branch fitur baru `feat/notes-validation` tidak memiliki riwayat umur branch sebelumnya. |
| File tak terlacak | Tidak ada sebelum perubahan Praktikum 1; `git status` menunjukkan worktree bersih. |
| Commit tambahan dari `main` | `ba29434 Revise README for Clean Architecture project` adalah commit terbaru yang diminta untuk dicatat dalam audit 16 commit. |

## Perbaikan Pesan Commit (Simulasi)

| Pesan lama | Pesan yang disarankan | Alasan |
| --- | --- | --- |
| `Praktikum 7 done` | `feat(notes): tambahkan aplikasi offline notes dan struktur awal` | Menjelaskan jenis perubahan dan fitur yang ditambahkan. |
| `Update README.md` | `docs(week5): perbarui panduan proyek penyimpanan offline` | Menjelaskan bahwa perubahan berupa dokumentasi dan menyebut lingkupnya. |
| `Add files via upload` | `docs(campus-notify): tambahkan bukti screenshot praktikum` | Menjelaskan isi berkas yang ditambahkan dan konteksnya. |

## Checklist Kesiapan Mid-Review

| Item pemeriksaan | Status | Bukti/catatan |
| --- | --- | --- |