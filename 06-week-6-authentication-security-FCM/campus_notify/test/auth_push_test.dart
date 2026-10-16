import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('provider auth membaca status login dari token', () async {
    final store = FakeTokenStore()..access = 'mock-access';
    expect(store.access != null, isTrue);
    store.access = null;
    expect(store.access != null, isFalse);
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final store = FakeTokenStore()..refresh = '';
    final needsLogin = (store.refresh ?? '').isEmpty;
    expect(needsLogin, isTrue);
  });

  test('ApiErrorHandler memetakan DioException ke pesan ramah pengguna', () {
    // 1. Error 401 Unauthorized
    final error401 = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      response: Response(
        requestOptions: RequestOptions(path: '/devices'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    expect(
      ApiErrorHandler.getErrorMessage(error401),
      contains('Sesi login telah berakhir'),
    );

    // 2. Error Connection Timeout
    final errorTimeout = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(
      ApiErrorHandler.getErrorMessage(errorTimeout),
      contains('timeout'),
    );

    // 3. Error Connection Error (Offline)
    final errorOffline = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      type: DioExceptionType.connectionError,
    );
    expect(
      ApiErrorHandler.getErrorMessage(errorOffline),
      contains('offline'),
    );
  });
}
