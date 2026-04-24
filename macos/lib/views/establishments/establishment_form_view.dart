// FILE: lib/views/establishments/establishment_form_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/establishment_provider.dart';

class EstablishmentFormView extends ConsumerStatefulWidget {
  final String? id;
  const EstablishmentFormView({super.key, this.id});

  @override
  ConsumerState<EstablishmentFormView> createState() =>
      _EstablishmentFormViewState();
}

class _EstablishmentFormViewState
    extends ConsumerState<EstablishmentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  File? _imageFile;
  bool _initialized = false;

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      Future.microtask(() =>
          ref.read(establishmentProvider.notifier).loadById(widget.id!));
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _preloadFields() {
    final item = ref.read(establishmentProvider).selected;
    if (item != null && !_initialized) {
      _nombreCtrl.text = item.nombre;
      _nitCtrl.text = item.nit;
      _direccionCtrl.text = item.direccion;
      _telefonoCtrl.text = item.telefono;
      _initialized = true;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (isEditing) {
      success = await ref.read(establishmentProvider.notifier).update(
            id: widget.id!,
            nombre: _nombreCtrl.text.trim(),
            nit: _nitCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            telefono: _telefonoCtrl.text.trim(),
            logoPath: _imageFile?.path,
          );
    } else {
      success = await ref.read(establishmentProvider.notifier).create(
            nombre: _nombreCtrl.text.trim(),
            nit: _nitCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            telefono: _telefonoCtrl.text.trim(),
            logoPath: _imageFile?.path,
          );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Establecimiento actualizado'
              : 'Establecimiento creado'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/establishments');
    } else if (mounted) {
      final error = ref.read(establishmentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Inténtalo de nuevo"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(establishmentProvider);

    if (isEditing && !_initialized && state.selected != null) {
      _preloadFields();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Establecimiento' : 'Nuevo Establecimiento'),
        leading: BackButton(
          onPressed: () => isEditing
              ? context.go('/establishments/${widget.id}')
              : context.go('/establishments'),
        ),
      ),
      body: state.isLoading && isEditing && !_initialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de imagen
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!,
                                    fit: BoxFit.cover,
                                    width: double.infinity),
                              )
                            : isEditing &&
                                    state.selected?.logo != null &&
                                    state.selected!.logo!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          state.selected!.logo!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imagePlaceholder(),
                                        ),
                                        Container(
                                          color:
                                              Colors.black.withValues(alpha: 0.3),
                                          child: const Center(
                                            child: Icon(Icons.edit,
                                                color: Colors.white,
                                                size: 32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _imagePlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campos del formulario
                    _buildField(
                      controller: _nombreCtrl,
                      label: 'Nombre',
                      icon: Icons.business,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _nitCtrl,
                      label: 'NIT',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _direccionCtrl,
                      label: 'Dirección',
                      icon: Icons.location_on,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _telefonoCtrl,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 28),

                    // Botón submit
                    ElevatedButton.icon(
                      onPressed: state.isSaving ? null : _submit,
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              isEditing ? Icons.save : Icons.add_circle),
                      label: Text(isEditing
                          ? 'Guardar cambios'
                          : 'Crear establecimiento'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Toca para seleccionar logo',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }
}