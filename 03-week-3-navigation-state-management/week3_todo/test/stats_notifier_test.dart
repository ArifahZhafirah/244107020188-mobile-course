import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('statsProvider mengembalikan 3 item saat sukses', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(statsProvider.future);

    expect(result.length, 3);
  });

  test('statsProvider melempar error saat forceFail = true', () async {
    // Override provider supaya pakai StatsNotifier(forceFail: true).
    // Hasilnya: error PASTI terjadi, tidak bergantung angka acak.
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(() => StatsNotifier(forceFail: true)),
      ],
    );
    addTearDown(container.dispose);

    // expectLater dengan throwsException memastikan error benar-benar muncul.
    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}