// FILE: lib/isolates/accident_isolate.dart

import '../models/accident_model.dart';

class AccidentStats {
  final Map<String, int> byClass;
  final Map<String, int> bySeverity;
  final Map<String, int> top5Neighborhoods;
  final Map<String, int> byDayOfWeek;

  const AccidentStats({
    required this.byClass,
    required this.bySeverity,
    required this.top5Neighborhoods,
    required this.byDayOfWeek,
  });
}

AccidentStats computeAccidentStats(List<Map<String, dynamic>> rawList) {
  final stopwatch = Stopwatch()..start();
  // ignore: avoid_print
  print('[Isolate] Iniciado — ${rawList.length} registros recibidos');

  final accidents = rawList.map(AccidentModel.fromJson).toList();

  // 1. Distribución por clase de accidente
  final byClass = <String, int>{};
  for (final a in accidents) {
    final raw = (a.claseAccidente ?? '').toLowerCase();
    final String key;
    if (raw.contains('choque')) {
      key = 'Choque';
    } else if (raw.contains('atropello')) {
      key = 'Atropello';
    } else if (raw.contains('volcamiento')) {
      key = 'Volcamiento';
    } else {
      key = 'Otros';
    }
    byClass[key] = (byClass[key] ?? 0) + 1;
  }

  // 2. Distribución por gravedad
  final bySeverity = <String, int>{};
  for (final a in accidents) {
    final raw = (a.gravedad ?? '').toLowerCase();
    final String key;
    if (raw.contains('muerto') || raw.contains('muerte')) {
      key = 'Con muertos';
    } else if (raw.contains('herido')) {
      key = 'Con heridos';
    } else {
      key = 'Solo daños';
    }
    bySeverity[key] = (bySeverity[key] ?? 0) + 1;
  }

  // 3. Top 5 barrios
  final allNeighborhoods = <String, int>{};
  for (final a in accidents) {
    final barrio = (a.barrio ?? '').trim();
    if (barrio.isEmpty) continue;
    allNeighborhoods[barrio] = (allNeighborhoods[barrio] ?? 0) + 1;
  }
  final sorted = allNeighborhoods.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top5Neighborhoods = Map.fromEntries(sorted.take(5));

  // 4. Distribución por día de la semana
  const dayOrder = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo',
  ];
  final byDayRaw = <String, int>{};
  for (final a in accidents) {
    final raw = (a.dia ?? '').trim();
    if (raw.isEmpty) continue;
    final normalized = raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    final key = _normalizeDayName(normalized);
    byDayRaw[key] = (byDayRaw[key] ?? 0) + 1;
  }
  final byDayOfWeek = <String, int>{};
  for (final day in dayOrder) {
    if (byDayRaw.containsKey(day)) {
      byDayOfWeek[day] = byDayRaw[day]!;
    }
  }
  for (final entry in byDayRaw.entries) {
    if (!byDayOfWeek.containsKey(entry.key)) {
      byDayOfWeek[entry.key] = entry.value;
    }
  }

  stopwatch.stop();
  // ignore: avoid_print
  print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');

  return AccidentStats(
    byClass: byClass,
    bySeverity: bySeverity,
    top5Neighborhoods: top5Neighborhoods,
    byDayOfWeek: byDayOfWeek,
  );
}

String _normalizeDayName(String raw) {
  const Map<String, String> aliases = {
    'Monday': 'Lunes',
    'Tuesday': 'Martes',
    'Wednesday': 'Miércoles',
    'Thursday': 'Jueves',
    'Friday': 'Viernes',
    'Saturday': 'Sábado',
    'Sunday': 'Domingo',
    'Lun': 'Lunes',
    'Mar': 'Martes',
    'Mie': 'Miércoles',
    'Mié': 'Miércoles',
    'Jue': 'Jueves',
    'Vie': 'Viernes',
    'Sab': 'Sábado',
    'Sáb': 'Sábado',
    'Dom': 'Domingo',
  };
  return aliases[raw] ?? raw;
}