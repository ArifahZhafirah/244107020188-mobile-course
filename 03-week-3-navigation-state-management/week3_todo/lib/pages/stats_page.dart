import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman statistik. ConsumerWidget supaya bisa membaca provider lewat ref.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch HANYA di dalam build -> UI rebuild saat state berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Kondisi 1: loading -> spinner.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Kondisi 2: error -> pesan + tombol retry.
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              const SizedBox(height: 12),
              FilledButton(
                // ref.read dipakai di callback (bukan build).
                // refresh() akan set state ke loading lalu ambil data lagi.
                onPressed: () =>
                    ref.read(statsProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),

        // Kondisi 3: success -> tampilkan daftar.
        data: (stats) => ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: stats.length,
  itemBuilder: (context, index) => Padding(
    padding: const EdgeInsets.only(bottom: 8), // jarak antar item
    child: Card(
      child: ListTile(
        leading: const Icon(Icons.bar_chart),
        title: Text(stats[index]),
      ),
    ),
  ),
),
      ),
    );
  }
}