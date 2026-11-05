// Reglas del formulario de cliente. Devuelven el mensaje de error o null.

String? validarNombre(String? valor) {
  final limpio = valor?.trim() ?? '';
  if (limpio.isEmpty) return 'Escribe el nombre del cliente.';
  if (limpio.length < 3) return 'El nombre es muy corto.';
  return null;
}

// Guatemala: 8 dígitos; se acepta con espacios, guiones o +502.
String? validarTelefono(String? valor) {
  var digitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
  if (digitos.isEmpty) return 'Escribe el teléfono.';
  if (digitos.length == 11 && digitos.startsWith('502')) {
    digitos = digitos.substring(3);
  }
  if (digitos.length != 8) return 'El teléfono debe tener 8 dígitos.';
  return null;
}

// "55123456" -> "5512 3456", como lo escribe Fredy.
String formatearTelefono(String valor) {
  var digitos = valor.replaceAll(RegExp(r'\D'), '');
  if (digitos.length == 11 && digitos.startsWith('502')) {
    digitos = digitos.substring(3);
  }
  if (digitos.length != 8) return valor.trim();
  return '${digitos.substring(0, 4)} ${digitos.substring(4)}';
}

// Primera llamada a las 9:00 del día elegido.
DateTime primeraLlamadaEn(int dias, [DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  return DateTime(h.year, h.month, h.day + dias, 9);
}
