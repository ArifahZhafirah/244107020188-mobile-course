# AI Challenge - Minggu 4

## 1. Prompt yang Digunakan
```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## 2. Verifikasi Checklist
- [x] **UI tidak memanggil Dio langsung**: Karena UI tidak dibuat (berdasarkan prompt), Dio hanya dipanggil melalui `CommentRepository`.
- [x] **`fromJson` aman null**: Ya, menggunakan pengecekan `(json['id'] as num?)?.toInt() ?? 0` dan `as String? ?? ''` sehingga tidak akan crash jika field hilang dari API.
- [x] **Pesan Error Ramah Pengguna**: Semua tipe `DioExceptionType` seperti timeout, connectionError, dan badResponse (404, 500) sudah dipetakan ke pesan ramah pengguna di fungsi `friendlyCommentErrorMessage`.
- [x] **`baseUrl` dan timeout terpusat**: Timeout terpusat di `CommentRepository` pada pemanggilan `fetchComments` menggunakan `Options(receiveTimeout: ..., sendTimeout: ...)` sesuai requirement, dan `baseUrl` mengikuti `api_client.dart` bawaan modul.
- [x] **Test AI menguji edge case (field hilang)**: Ya, Unit test `test/comment_test.dart` secara khusus mengosongkan parameter `name`, `email`, dan `body` lalu memverifikasi bahwa model mengembalikan string kosong (fallback).
- [x] **flutter test lulus**: Semua test untuk comment model berhasil lulus.
