// FILE: lib/providers/establishment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/establishment_model.dart';
import '../services/establishment_service.dart';

// Estado
class EstablishmentState {
  final bool isLoading;
  final List<EstablishmentModel> establishments;
  final EstablishmentModel? selected;
  final String? error;
  final bool isSaving;
  final bool isDeleting;

  const EstablishmentState({
    this.isLoading = false,
    this.establishments = const [],
    this.selected,
    this.error,
    this.isSaving = false,
    this.isDeleting = false,
  });

  EstablishmentState copyWith({
    bool? isLoading,
    List<EstablishmentModel>? establishments,
    EstablishmentModel? selected,
    String? error,
    bool? isSaving,
    bool? isDeleting,
  }) {
    return EstablishmentState(
      isLoading: isLoading ?? this.isLoading,
      establishments: establishments ?? this.establishments,
      selected: selected ?? this.selected,
      error: error,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// Notifier
class EstablishmentNotifier extends StateNotifier<EstablishmentState> {
  final EstablishmentService _service;

  EstablishmentNotifier(this._service) : super(const EstablishmentState());

  // GET todos
  Future<void> loadAll() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.fetchAll();
      state = state.copyWith(isLoading: false, establishments: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // GET uno
  Future<void> loadById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final item = await _service.fetchById(id);
      state = state.copyWith(isLoading: false, selected: item);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // POST crear
  Future<bool> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final nuevo = await _service.create(
        nombre: nombre,
        nit: nit,
        direccion: direccion,
        telefono: telefono,
        logoPath: logoPath,
      );
      state = state.copyWith(
        isSaving: false,
        establishments: [...state.establishments, nuevo],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  // POST update con _method=PUT
  Future<bool> update({
    required String id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final updated = await _service.update(
        id: id,
        nombre: nombre,
        nit: nit,
        direccion: direccion,
        telefono: telefono,
        logoPath: logoPath,
      );
      final list = state.establishments.map((e) {
        return e.id.toString() == id ? updated : e;
      }).toList();
      state = state.copyWith(
        isSaving: false,
        establishments: list,
        selected: updated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  // DELETE
  Future<bool> delete(String id) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _service.delete(id);
      final list =
          state.establishments.where((e) => e.id.toString() != id).toList();
      state = state.copyWith(
        isDeleting: false,
        establishments: list,
        selected: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }
}

// Provider
final establishmentProvider =
    StateNotifierProvider<EstablishmentNotifier, EstablishmentState>((ref) {
  final service = ref.watch(establishmentServiceProvider);
  return EstablishmentNotifier(service);
});