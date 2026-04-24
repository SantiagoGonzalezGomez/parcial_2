// FILE: lib/views/establishments/establishment_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/establishment_provider.dart';

class EstablishmentDetailView extends ConsumerStatefulWidget {
  final String id;
  const EstablishmentDetailView({super.key, required this.id});

  @override
  ConsumerState<EstablishmentDetailView> createState() =>
      _EstablishmentDetailViewState();
}

class _EstablishmentDetailViewState
    extends ConsumerState<EstablishmentDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(establishmentProvider.notifier).loadById(widget.id));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar establecimiento'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este establecimiento? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(establishmentProvider.notifier)
          .delete(widget.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Establecimiento eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/establishments');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(establishmentProvider);
    final item = state.selected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        leading: BackButton(onPressed: () => context.go('/establishments')),
        actions: [
          if (item != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  context.push('/establishments/${widget.id}/edit'),
            ),
          if (item != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(state.error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(establishmentProvider.notifier)
                            .loadById(widget.id),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : item == null
                  ? const Center(child: Text('No encontrado'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo grande
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: item.logo != null &&
                                      item.logo!.isNotEmpty
                                  ? Image.network(
                                      item.logo!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _logoPlaceholder(),
                                    )
                                  : _logoPlaceholder(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Campos
                          _DetailCard(
                            children: [
                              _DetailRow(
                                  icon: Icons.business,
                                  label: 'Nombre',
                                  value: item.nombre),
                              const Divider(),
                              _DetailRow(
                                  icon: Icons.badge,
                                  label: 'NIT',
                                  value: item.nit),
                              const Divider(),
                              _DetailRow(
                                  icon: Icons.location_on,
                                  label: 'Dirección',
                                  value: item.direccion),
                              const Divider(),
                              _DetailRow(
                                  icon: Icons.phone,
                                  label: 'Teléfono',
                                  value: item.telefono),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Botones
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(
                                      '/establishments/${widget.id}/edit'),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () =>
                                      _confirmDelete(context),
                                  icon: state.isDeleting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.delete),
                                  label: const Text('Eliminar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.local_parking,
          size: 64, color: Color(0xFF1565C0)),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}