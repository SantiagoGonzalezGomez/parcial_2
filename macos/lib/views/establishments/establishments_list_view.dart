// FILE: lib/views/establishments/establishments_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/establishment_model.dart';
import '../../providers/establishment_provider.dart';

class EstablishmentsListView extends ConsumerStatefulWidget {
  const EstablishmentsListView({super.key});

  @override
  ConsumerState<EstablishmentsListView> createState() =>
      _EstablishmentsListViewState();
}

class _EstablishmentsListViewState
    extends ConsumerState<EstablishmentsListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(establishmentProvider.notifier).loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(establishmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Establecimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(establishmentProvider.notifier).loadAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/establishments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EstablishmentState state) {
    if (state.error != null && state.establishments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(establishmentProvider.notifier).loadAll(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Skeleton items de muestra mientras carga
    final skeletonItems = List.generate(
      6,
      (_) => const EstablishmentModel(
        nombre: 'Nombre del parqueadero',
        nit: '000-000-0000',
        direccion: 'Dirección de ejemplo larga',
        telefono: '3001234567',
      ),
    );

    final items =
        state.isLoading ? skeletonItems : state.establishments;

    if (!state.isLoading && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No hay establecimientos registrados',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/establishments/new'),
              icon: const Icon(Icons.add),
              label: const Text('Crear primero'),
            ),
          ],
        ),
      );
    }

    return Skeletonizer(
      enabled: state.isLoading,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _EstablishmentTile(
            item: item,
            onTap: () => context.push('/establishments/${item.id}'),
          );
        },
      ),
    );
  }
}

class _EstablishmentTile extends StatelessWidget {
  final EstablishmentModel item;
  final VoidCallback onTap;

  const _EstablishmentTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.logo != null && item.logo!.isNotEmpty
                    ? Image.network(
                        item.logo!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _logoPlaceholder(),
                      )
                    : _logoPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text('NIT: ${item.nit}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    Text(item.direccion,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    Text(item.telefono,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.local_parking,
          color: Color(0xFF1565C0), size: 28),
    );
  }
}