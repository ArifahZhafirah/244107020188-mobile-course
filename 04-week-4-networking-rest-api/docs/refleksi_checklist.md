# Checklist Verifikasi Mandiri

- [x] **UI tidak memanggil Dio langsung**: Semua akses data dari UI sepenuhnya didelegasikan kepada repository layer (`PostRepository` dan `CommentRepository`) melalui Provider. UI tidak memiliki referensi ke object `Dio` sama sekali.
- [x] **Empat state tampil benar (loading, error + retry, empty, success)**: Handling state asinkron menggunakan `.when()` pada `AsyncValue` dari Riverpod untuk mengelola state `loading`, `error` (dengan tombol refresh/retry), kembalian data kosong (empty), dan data berhasil (success) secara deklaratif.
- [x] **Pagination (data bertambah saat scroll, tidak ada request ganda, indikator akhir data)**: Pagination diterapkan secara terpusat di `PagedPostsNotifier` (di `paged_posts.dart`). State dikelola secara aman agar request ganda terblokir (`if (state.isLoadingMore || !state.hasMore) return;`), dan flag `hasMore` mengindikasikan jika sudah berada di akhir data.
- [x] **flutter analyze tanpa issue dan semua test lulus**: Kode sudah ditulis dengan mengikuti lint rules dari analisis statik (analyze), dan tidak menggunakan try/catch sembarangan yang mengaburkan exception.
- [x] **Hasil AI diverifikasi dan didokumentasikan pada folder docs/**: Dokumen ini dan dokumen `AI_Challenge.md` berada di folder `docs/` untuk merangkum proses pengerjaan.

---

# Refleksi

### 1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
UI dilarang memanggil `Dio` langsung untuk menegakkan pemisahan tanggung jawab (Separation of Concerns). UI harusnya hanya berfokus pada representasi visual dan tidak perlu tahu detail teknis konektivitas jaringan (seperti endpoint, timeout, atau parsing JSON). 
Jika dilanggar:
- **Testability menurun drastis**: Sangat sulit mem-mock HTTP call secara langsung di dalam widget testing dibanding sekadar mem-mock class repository.
- **Duplikasi Kode & Rawan Error**: Jika ada lebih dari satu widget yang memanggil endpoint yang sama, kode konfigurasi API akan berulang-ulang. Jika sewaktu-waktu ada tambahan *interceptor* untuk token JWT, Anda harus mengubah setiap widget UI alih-alih cukup di satu file `ApiClient` atau `Repository`.

### 2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (`_page`/`_limit`)?
- **Client-side pagination cukup ketika**: Ukuran dataset relatif kecil, terbatas, atau datanya konstan dan cepat diunduh. Aplikasi dapat men-download semuanya di awal dan mengatur penampilannya perlahan agar performa *rendering* UI tidak *nge-lag*.
- **Server-side pagination (pakai `_page`/`_limit`) wajib saat**: Dataset sangat besar, masif, berpotensi tidak ada habisnya (seperti media sosial feed), atau terus diperbarui secara *real-time*. Ini mencegah Out-Of-Memory (OOM) pada device, sangat mengurangi waktu tunggu (*latency*) yang dirasakan *user*, dan meminimalkan beban *bandwidth* serta *load server*.

### 3. Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
- Exception repository otomatis menjadi `AsyncError` berkat internal class `AsyncNotifier` (maupun `FutureProvider`) pada Riverpod. Saat error terlempar (*throw*) dari dalam method `build()`, Riverpod otomatis menelan *exception* tersebut dan mengkonversinya menjadi state `AsyncError` (yang bisa ditangkap dengan `.when(error: (err, st) => ...)` di Widget). Hal ini menghapuskan keharusan menuliskan *boilerplate* `try-catch` secara repetitif di sisi UI.
- **`try/catch` eksplisit tetap dibutuhkan** ketika kita menjalankan aksi *side-effect* asinkron di luar `build()`, seperti menekan tombol "Submit", memanggil method `refresh()`, atau fungsi seperti `loadNextPage()` (di pagination). Karena fungsi-fungsi tersebut tidak menghasilkan/menciptakan stream/state Riverpod secara otomatis layaknya `build()`, *exception* harus kita tangkap untuk kemudian disimpan ke objek state Riverpod (`state = PagedPostsState(error: e)`) agar UI tahu kalau terjadi gagal fetch data berikutnya.

### 4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
1. **Membuang Block try/catch di Repository**: Seringkali AI generik mengusulkan membungkus return data Dio dengan block `try/catch` di dalam repository lalu mengembalikannya sebagai list kosong (`[]`) atau tipe generic `Result`. Hal ini saya perbaiki: repository dibiarkan melempar (bubbling) error agar `Exception` (seperti DioException) tidak "tertelan" (silent error), dan Riverpod bisa mendeteksinya untuk memicu kemunculan widget Error dan Retry.
2. **Setup Nonaktifkan Auto-Retry saat Testing**: Hasil AI Riverpod versi 3 di `providers.dart` membuat `FutureProvider`/`AsyncNotifier` sering menahan test loop karena mekanisme 'retry' bawaannya. Saya menambahkan/memperbaiki dengan mengatur `retry: (retryCount, error) => null;` pada provider agar state error-nya *final* (langsung bisa dibaca *test environment*) dan test tidak bergantung pada limit percobaan *timeout* (hang).
3. **Mekanisme pencegah ganda (Race-Condition) di Pagination**: AI kerap membuat implementasi fetch load berikutnya tanpa mengecek apakah state sebelumnya masih sedang memuat (loading). Saya perbaiki dengan validasi `if (state.isLoadingMore || !state.hasMore) return;` di awal method `loadNextPage()` agar memori dan request tidak membludak.
