import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  StatsNotifier({this.forceFail = false});

  /// Kalau true, _fetch() SELALU gagal.
  /// Dipakai di test supaya hasilnya deterministik.
  final bool forceFail;

  final _random = Random();

  @override
  Future<List<String>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 2));

    // Kalau dipaksa gagal, langsung lempar error (deterministik).
    if (forceFail) {
      throw Exception('Gagal terhubung ke server');
    }

    // Kalau tidak, tetap simulasikan gagal 30% untuk aplikasi nyata.
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal terhubung ke server');
    }

    return ['Total Tugas: 12', 'Selesai: 7', 'Belum Selesai: 5'];
  }
}

/// Provider default (dipakai aplikasi) -> tidak dipaksa gagal.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);