// FILE: lib/providers/accident_provider.dart
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../isolates/accident_isolate.dart';
import '../services/accident_service.dart';

// Estado
class AccidentState {
  final bool isLoading;
  final AccidentStats? stats;
  final int totalRecords;
  final String? error;

  const AccidentState({
    this.isLoading = false,
    this.stats,
    this.totalRecords = 0,
    this.error,
  });

  AccidentState copyWith({
    bool? isLoading,
    AccidentStats? stats,
    int? totalRecords,
    String? error,
  }) {
    return AccidentState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      totalRecords: totalRecords ?? this.totalRecords,
      error: error,
    );
  }
}

// Notifier
class AccidentNotifier extends StateNotifier<AccidentState> {
  final AccidentService _service;

  AccidentNotifier(this._service) : super(const AccidentState());

  Future<void> loadAccidents() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Fetch desde API
      final accidents = await _service.fetchAccidents();

      // 2. Convertir a raw maps para pasar al Isolate
      final rawList = accidents
          .map((a) => {
                'clase_de_accidente': a.claseAccidente,
                'gravedad_del_accidente': a.gravedad,
                'barrio_hecho': a.barrio,
                'dia': a.dia,
              })
          .toList();

      // 3. Procesar en Isolate
      final stats = await Isolate.run(() => computeAccidentStats(rawList));

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        totalRecords: accidents.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider
final accidentProvider =
    StateNotifierProvider<AccidentNotifier, AccidentState>((ref) {
  final service = ref.watch(accidentServiceProvider);
  return AccidentNotifier(service);
});