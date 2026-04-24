// FILE: lib/models/accident_model.dart

class AccidentModel {
  final String? claseAccidente;
  final String? gravedad;
  final String? barrio;
  final String? dia;

  const AccidentModel({
    this.claseAccidente,
    this.gravedad,
    this.barrio,
    this.dia,
  });

  factory AccidentModel.fromJson(Map<String, dynamic> json) {
    return AccidentModel(
      claseAccidente: json['clase_de_accidente']?.toString().trim(),
      gravedad: json['gravedad_del_accidente']?.toString().trim(),
      barrio: json['barrio_hecho']?.toString().trim(),
      dia: json['dia']?.toString().trim(),
    );
  }
}