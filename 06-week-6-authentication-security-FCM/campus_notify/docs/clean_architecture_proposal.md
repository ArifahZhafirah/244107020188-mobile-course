# Usulan Feature-First Clean Architecture

Dokumen ini mencatat usulan refaktor untuk `campus_notify`, bukan klaim bahwa
refaktor sudah diterapkan. Pemeriksaan dilakukan terhadap `lib/` dan
`test/auth_push_test.dart` yang ada saat dokumen ini ditulis.

## Keputusan arsitektur

Gunakan feature-first: setiap fitur memiliki `presentation`, `domain`, dan
`data`. Kontrak repository berada di `domain`; implementasinya berada di
`data`. `core` hanya untuk kemampuan lintas fitur (network, routing, notifikasi,
dan wiring DI), bukan tempat menaruh semua kode aplikasi.

```text
lib/
  app/
    app.dart
    app_router.dart
  core/
    di/
      app_providers.dart
    network/
      dio_provider.dart
      dio_error_mapper.dart
    notifications/
      push_service.dart
      firebase_messaging_background_handler.dart
    routing/
      app_routes.dart
      notification_route_parser.dart
  features/
    auth/
      domain/
        entities/auth_session.dart
        repositories/auth_repository.dart
      data/
        datasources/auth_remote_data_source.dart
        datasources/secure_token_data_source.dart
        models/auth_session_model.dart
        repositories/auth_repository_impl.dart
      presentation/
        pages/login_page.dart
        providers/auth_notifier.dart
    announcements/
      domain/
        entities/announcement.dart
        repositories/announcements_repository.dart
      data/
        datasources/announcements_remote_data_source.dart
        models/announcement_model.dart
        repositories/announcements_repository_impl.dart
      presentation/
        pages/announcements_page.dart
        pages/announcement_detail_page.dart
        providers/announcements_provider.dart
        widgets/announcement_card.dart
```

`auth_session_model.dart` dan `announcement_model.dart` hanya diperlukan bila
ada kontrak serialisasi dari backend atau storage. Sampai endpoint tersedia,
data contoh dapat berada di mock data source di dalam `announcements/data`;
jangan jadikan daftar contoh sebagai sumber data tersembunyi di widget.
`home_page.dart` dapat menjadi `announcements_page.dart`; pindahkan kartu
pengumuman ke widget terpisah hanya bila reuse atau ukuran halaman memang
membenarkannya. Kartu status FCM yang bersifat diagnostik sebaiknya menjadi
widget/halaman status notifikasi, bukan bagian dari domain pengumuman.

## Tujuan setiap file lama

| File lama | Tujuan baru | Aksi dan alasan |
|---|---|---|
| `lib/data/auth_repository.dart` | `features/auth/domain/entities/auth_session.dart`, `features/auth/domain/repositories/auth_repository.dart`, dan `features/auth/data/repositories/auth_repository_impl.dart` (atau mock data source) | Pecah: `AuthSession` adalah data domain; interface repository menjadi kontrak domain; login demo/mock atau panggilan HTTP adalah detail data. Kredensial dan token demo jangan dipindah ke entity. |
| `lib/data/api_client.dart` | `core/network/dio_provider.dart` dan bagian interceptor auth di `features/auth/data/` | Pecah: konfigurasi Dio dasar dapat dipakai lintas fitur, sedangkan refresh-token dan retry adalah detail autentikasi/data. Hindari membuat Dio baru di widget atau FCM service. |
| `lib/data/api_errors.dart` | `core/network/dio_error_mapper.dart` | Pindahkan hanya jika error mapping masih dipakai. Isinya bergantung pada Dio, sehingga tidak boleh masuk domain; pesan untuk pengguna sebaiknya disajikan melalui state/UI. Jika digantikan mekanisme error lain, hapus helper dan tesnya setelah referensi dihapus. |
| `lib/data/announcement_data.dart` | `features/announcements/domain/entities/announcement.dart`, `data/models/announcement_model.dart`, dan mock data source bila masih diperlukan | Pecah: `Announcement` adalah entity; mapping JSON menjadi tanggung jawab model; `sampleAnnouncements` adalah data mock, bukan entity atau tanggung jawab halaman. |
| `lib/data/token_store.dart` | `features/auth/data/datasources/secure_token_data_source.dart` | Pindahkan sebagai adapter `flutter_secure_storage`. Repository auth mengatur pemakaian session; widget/domain tidak mengenal package storage. |
| `lib/pages/login_page.dart` | `features/auth/presentation/pages/login_page.dart` | Pindahkan UI dan validasi form. Halaman memanggil notifier/provider, bukan implementasi repository atau Dio. |
| `lib/pages/home_page.dart` | `features/announcements/presentation/pages/announcements_page.dart` ditambah widget status notifikasi bila diperlukan | Pecah tanggung jawab daftar announcement dari status/debug FCM. Jangan membuat banyak widget kecil tanpa kebutuhan reuse atau keterbacaan. |
| `lib/pages/announcement_page.dart` | `features/announcements/presentation/pages/announcement_detail_page.dart` | Pindahkan UI detail. Ambil data melalui provider/repository berdasarkan ID, bukan `sampleAnnouncements.firstWhere` di halaman. |
| `lib/providers/auth_provider.dart` | `features/auth/presentation/providers/auth_notifier.dart`; binding implementasi pindah ke `core/di/app_providers.dart` | Pisahkan state/UI-facing notifier dari composition root. Notifier bergantung pada interface `AuthRepository`. |
| `lib/messaging/push_service.dart` | `core/notifications/push_service.dart` dan `core/notifications/firebase_messaging_background_handler.dart`; pengiriman token melalui data source/repository yang diinjeksi | Pisahkan integrasi Firebase/notification lifecycle dari HTTP dan routing. Ganti singleton dan Dio internal dengan dependency dari provider; callback navigasi tetap diberikan dari app/router tanpa `BuildContext`. |
| `lib/routes.dart` | `core/routing/app_routes.dart` dan `core/routing/notification_route_parser.dart` | Pindahkan konstanta rute dan parser payload yang murni. Pertahankan satu definisi path agar router UI dan deep link FCM konsisten. |
| `lib/main.dart` | `main.dart` tetap sebagai entry point; router/root widget ke `app/app_router.dart` dan `app/app.dart` bila pemisahan membantu | Tetap inisialisasi binding/Firebase, `ProviderScope`, dan jalankan app. Hindari membuat repository langsung di entry point. Jangan memecah file ini bila router tetap ringkas. |
| `test/auth_push_test.dart` | Tes unit per layer/fitur, misalnya `test/features/auth/...`, `test/features/announcements/...`, `test/core/routing/...` | Pecah tes parser rute, repository/notifier auth, dan mapper error. Tes saat ini untuk `FakeTokenStore` hanya menguji boolean lokal, bukan perilaku provider/repository sesungguhnya; ganti dengan dependency fake yang diinjeksi. |

## Repository, entity, dan batas dependency

- `AuthRepository` dan `AnnouncementsRepository` adalah interface di masing-masing
  folder `domain/repositories/`; `AuthRepositoryImpl` dan
  `AnnouncementsRepositoryImpl` berada di `data/repositories/`.
- Entity hanya memuat konsep dan nilai domain. Tidak ada `toMap`, `fromMap`,
  `toJson`, atau `fromJson` pada entity. Konversi transport/storage ditempatkan
  di model data.
- Domain hanya mengimpor Dart inti dan tipe domain. Tidak boleh mengimpor
  Flutter, Riverpod, Dio, SQLite, Firebase, maupun package storage.
- Kegagalan Dio/Firebase/storage diterjemahkan di batas data menjadi hasil/error
  yang dipahami presentation; jangan mengekspos `DioException` ke entity atau
  interface domain.
- `Announcement` dari file lama tidak memiliki method mapping dan `AuthSession`
  juga merupakan kelas data sederhana; jangan menambahkan serialisasi pada
  keduanya.

## Use case: kapan perlu dan kapan berlebihan

Untuk daftar, detail, tambah, ubah, atau hapus yang hanya meneruskan satu
operasi, panggil interface repository dari notifier/provider. Contohnya:

```dart
final announcementsProvider = FutureProvider<List<Announcement>>((ref) {
  return ref.watch(announcementsRepositoryProvider).getAnnouncements();
});
```

Jangan membuat `GetAnnouncements`, `GetAnnouncementById`, `CreateAnnouncement`,
`UpdateAnnouncement`, dan `DeleteAnnouncement` yang masing-masing hanya
meneruskan satu pemanggilan repository. Lapisan tambahan itu tidak memberi
kebijakan/orkestrasi baru dan menambah file, constructor, serta tes yang harus
dirawat.

Use case layak ditambahkan saat ada aturan bisnis atau orkestrasi yang nyata,
misalnya satu proses login yang harus memvalidasi kebijakan sesi, meminta
kredensial ke remote, menyimpan session secara aman, lalu mendaftarkan device
token; atau satu aksi yang mengoordinasikan beberapa repository dan dipakai
oleh lebih dari satu UI. Jika proses itu tetap sederhana dan menjadi tanggung
jawab implementasi repository, repository langsung tetap pilihan yang wajar.
Jangan menambahkan use case hanya agar setiap method memiliki kelas sendiri.

## Wiring dependency injection dengan Riverpod

Tidak perlu package DI tambahan. Provider menjadi composition root yang
menghubungkan implementasi konkret ke interface. Provider berikut adalah
sketsa penempatan; nama constructor perlu disesuaikan saat refaktor:

```dart
// core/di/app_providers.dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  ref.onDispose(dio.close);
  return dio;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final secureTokenDataSourceProvider = Provider<SecureTokenDataSource>((ref) {
  return SecureTokenDataSourceImpl(const FlutterSecureStorage());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenStore: ref.watch(secureTokenDataSourceProvider),
  );
});

final announcementsRepositoryProvider =
    Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepositoryImpl(
    remote: AnnouncementsRemoteDataSourceImpl(ref.watch(dioProvider)),
  );
});
```

Notifier berada dekat fitur dan hanya membaca interface:

```dart
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(authRepositoryProvider).hasSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      return true;
    });
  }
}
```

Widget cukup `watch` state dan `read` notifier/provider. Ia tidak membuat
`AuthRepositoryImpl`, `Dio`, data source, atau storage. Firebase service juga
di-expose melalui provider dan menerima dependency yang diperlukan, bukan
memanggil singleton internal untuk membuat HTTP client sendiri. Untuk tes,
`ProviderContainer`/`ProviderScope` dapat mengganti provider dengan fake.

## Trade-off

| Keputusan | Keuntungan | Biaya/risiko |
|---|---|---|
| Feature-first dengan kontrak repository di domain | Fitur lebih kohesif; aturan dependency mudah diaudit; data source dapat diganti tanpa mengubah UI/domain | Lebih banyak folder/berkas daripada struktur berdasarkan jenis global; untuk satu layar statis terasa berlebihan |
| Model terpisah dari entity | Domain bersih dari format API/storage; perubahan JSON tidak menyebar ke UI | Ada pemetaan model-entity tambahan. Untuk fixture mock yang belum punya kontrak eksternal, model tidak perlu dibuat lebih awal |
| Repository langsung untuk CRUD sederhana | Sedikit boilerplate dan alur UI → interface mudah diikuti | Notifier tetap tahu operasi repository; jika aturan bisnis bertambah, ekstrak use case saat itu |
| Provider sebagai DI dan composition root | Tidak menambah dependency; mudah override saat tes; implementasi konkret terpusat | Provider graph dapat menjadi besar; bila tumbuh, pecah file provider per fitur tetapi pertahankan satu pola wiring |
| Push service ditempatkan sebagai integrasi lintas fitur | Lifecycle FCM tidak tercampur dengan widget/HTTP; deep-link tetap dapat diarahkan lewat router | Pemisahan background handler, token registration, dan UI status menambah beberapa file; lakukan hanya pada batas tanggung jawab yang nyata |

## Hasil AI Verification Checklist

| Pemeriksaan | Temuan dari source saat ini | Keputusan |
|---|---|---|
| Interface repository di domain, implementasi di data | `lib/` saat ini belum memiliki folder `domain/` atau `features/`; `AuthRepository` saat ini kelas konkret di `lib/data/auth_repository.dart`. Jadi syarat ini belum terpenuhi. | Refaktor menempatkan interface di `features/<feature>/domain/repositories/` dan implementasi di `data/repositories/`. |
| Domain bebas Flutter/Dio/SQLite/Firebase | Belum ada source domain pada `campus_notify/lib` untuk diaudit. Pemeriksaan `rg` untuk `domain`, `presentation`, dan `features/auth|announcements` tidak menemukan match. | Setelah domain dibuat, ulangi grep pada folder domain dan tolak import package/framework di sana. |
| Use case satu-baris per CRUD | Tidak ada folder use case untuk announcement saat ini. | Jangan membuat use case untuk CRUD satu operasi; tulis alasannya di atas dan tambahkan hanya bila ada aturan/orkestrasi. |
| Entity bebas mapping | Saat ini `Announcement` adalah kelas di file `data/announcement_data.dart` tanpa method mapping; `AuthSession` juga kelas sederhana tanpa mapping di `data/auth_repository.dart`. | Pertahankan entity polos; mapping baru menjadi tanggung jawab model di data. |
| DI terpusat dan tidak membuat repository di widget | Ada `authRepositoryProvider`, tetapi provider itu membangun class konkret. `PushService.instance` digunakan oleh `HomePage`, dan service membuat Dio sendiri. | Pindahkan semua binding konkret ke `core/di/app_providers.dart`; inject push service dan repository lewat provider. |
| Widget memanggil Dio langsung | Verifikasi `rg` pada `lib/pages` untuk `Dio(`, `package:dio`, `.get(`, `.post(` tidak menemukan match. Dio digunakan di `lib/data/api_client.dart` dan `lib/messaging/push_service.dart`, bukan langsung di halaman. Namun `HomePage` membaca data contoh langsung dan memanggil singleton `PushService`. | Koreksi catatan awal: masalah aktual yang terlihat adalah halaman terikat ke data contoh/singleton service; bukan pemanggilan Dio langsung oleh widget. |

Contoh audit source yang digunakan (jalankan dari root repository):

```powershell
rg -n "package:dio|Dio\(|\.get\(|\.post\(" `
  "06-week-6-authentication-security-FCM/campus_notify/lib/pages" -g "*.dart"

rg -n "package:flutter|package:dio|sqflite|firebase|flutter_secure_storage" `
  "06-week-6-authentication-security-FCM/campus_notify/lib/features" -g "*.dart"
```

Perintah kedua belum menghasilkan audit domain aktual karena folder `features`
belum ada. Setelah refaktor, jalankan pencarian pada setiap
`features/*/domain/` dan tinjau semua hasil; domain tidak boleh mengimpor
framework atau SDK tersebut.
