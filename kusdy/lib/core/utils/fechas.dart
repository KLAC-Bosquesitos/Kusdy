// Fechas en español sin paquetes extra. Cuando se agregue `intl` (fase 0),
// estas funciones se pueden cambiar por DateFormat sin tocar las pantallas.

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const _dias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

// "Octubre 2026"
String mesYAnio(DateTime fecha) {
  final mes = _meses[fecha.month - 1];
  return '${mes[0].toUpperCase()}${mes.substring(1)} ${fecha.year}';
}

// "jueves 22 de octubre"
String diaLargo(DateTime fecha) {
  return '${_dias[fecha.weekday - 1]} ${fecha.day} de ${_meses[fecha.month - 1]}';
}

// "09:30"
String hora(DateTime fecha) {
  final h = fecha.hour.toString().padLeft(2, '0');
  final m = fecha.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

// El mismo día del calendario, sin importar la hora.
bool mismoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// La fecha a las 00:00, para comparar y guardar días sin hora.
DateTime soloDia(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);
