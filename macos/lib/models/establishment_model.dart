// FILE: lib/models/establishment_model.dart

class EstablishmentModel {
  final int? id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String? logo;

  const EstablishmentModel({
    this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    this.logo,
  });

  factory EstablishmentModel.fromJson(Map<String, dynamic> json) {
    return EstablishmentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      nombre: json['nombre']?.toString() ?? '',
      nit: json['nit']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
      };

  EstablishmentModel copyWith({
    int? id,
    String? nombre,
    String? nit,
    String? direccion,
    String? telefono,
    String? logo,
  }) {
    return EstablishmentModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      logo: logo ?? this.logo,
    );
  }
}