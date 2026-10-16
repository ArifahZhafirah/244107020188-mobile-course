import 'package:dio/dio.dart';

/// Kelas helper untuk memetakan error jaringan dan HTTP (DioException)
/// menjadi pesan teks yang ramah dan mudah dipahami oleh pengguna.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Mengonversi `DioException` atau objek error umum menjadi pesan Indonesia yang jelas.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi ke server timeout. Silakan periksa kembali jaringan internet Anda.';

        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server (offline). Pastikan perangkat terhubung ke internet.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Sesi login telah berakhir. Silakan login kembali.';
          } else if (statusCode == 403) {
            return 'Anda tidak memiliki hak akses untuk tindakan ini.';
          } else if (statusCode == 404) {
            return 'Data atau layanan yang diminta tidak ditemukan (404).';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Terjadi gangguan pada server ($statusCode). Silakan coba beberapa saat lagi.';
          }
          return 'Terjadi kesalahan respons server: ${error.response?.statusMessage ?? statusCode}.';

        case DioExceptionType.cancel:
          return 'Permintaan data dibatalkan.';

        case DioExceptionType.badCertificate:
          return 'Sertifikat keamanan server tidak valid.';

        case DioExceptionType.unknown:
        default:
          return 'Terjadi kesalahan jaringan yang tidak terduga. Silakan coba lagi.';
      }
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'Terjadi kesalahan yang tidak diketahui.';
  }
}
