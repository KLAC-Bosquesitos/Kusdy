import 'package:url_launcher/url_launcher.dart';

// Solo dígitos; los números de Guatemala sin código de país llevan +502.
String telefonoInternacional(String telefono) {
  final digitos = telefono.replaceAll(RegExp(r'\D'), '');
  return digitos.length == 8 ? '502$digitos' : digitos;
}

// Abre el marcador con el número listo. Devuelve false si no se pudo.
Future<bool> llamar(String telefono) {
  return launchUrl(Uri(scheme: 'tel', path: telefono.replaceAll(' ', '')));
}

Future<bool> abrirWhatsApp(String telefono) {
  return launchUrl(
    Uri.parse('https://wa.me/${telefonoInternacional(telefono)}'),
    mode: LaunchMode.externalApplication,
  );
}
