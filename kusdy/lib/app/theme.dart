import 'package:flutter/material.dart';

// Paleta de Kusdy, basada en el logo de Energica Solar.
// Es el único lugar donde se escribe un Color(0xFF...): las pantallas usan
// KusdyColors para que un ajuste de marca se haga en un solo lugar.
class KusdyColors {
  static const primario = Color(0xFF1E5BC5);
  static const primarioOscuro = Color(0xFF1E4180);
  static const primarioSuave = Color(0xFFE8F0FC);
  static const acento = Color(0xFFFD6512);
  static const acentoTexto = Color(0xFFB84A0A);
  static const acentoSuave = Color(0xFFFFEDE3);

  static const fondo = Color(0xFFF5F7FA);
  static const superficie = Color(0xFFFFFFFF);
  static const texto = Color(0xFF15212A);
  static const textoSecundario = Color(0xFF4B5A6E);
  static const borde = Color(0xFFD5DCE6);
  static const bordeFuerte = Color(0xFFA9B4C6);

  static const vencido = Color(0xFFB3261E);
  static const vencidoSuave = Color(0xFFFDECEA);
  static const exito = Color(0xFF1F6B3A);
  static const exitoSuave = Color(0xFFE3F2E8);
  static const aviso = Color(0xFF8A5A00);
  static const avisoSuave = Color(0xFFFFF4E5);
}

final kusdyTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: KusdyColors.fondo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: KusdyColors.primario,
    primary: KusdyColors.primario,
    onPrimary: Colors.white,
    secondary: KusdyColors.acento,
    onSecondary: KusdyColors.texto, // nunca texto blanco sobre naranja
    error: KusdyColors.vencido,
    surface: KusdyColors.superficie,
    onSurface: KusdyColors.texto,
  ),
  inputDecorationTheme: _camposDeFormulario,
);

// Campos de formulario más legibles (pedido de Freddy y Amilcar).
// La etiqueta flotante se dibuja al 75 %, por eso va en 22.
Color _colorEtiqueta(Set<WidgetState> estados) {
  if (estados.contains(WidgetState.error)) return KusdyColors.vencido;
  if (estados.contains(WidgetState.focused)) return KusdyColors.primario;
  return KusdyColors.primarioOscuro;
}

OutlineInputBorder _borde(Color color, double grosor) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: color, width: grosor),
);

final _camposDeFormulario = InputDecorationTheme(
  filled: true,
  fillColor: KusdyColors.superficie,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  labelStyle: WidgetStateTextStyle.resolveWith(
    (estados) => TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: estados.contains(WidgetState.error)
          ? KusdyColors.vencido
          : KusdyColors.textoSecundario,
    ),
  ),
  floatingLabelStyle: WidgetStateTextStyle.resolveWith(
    (estados) => TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _colorEtiqueta(estados),
    ),
  ),
  hintStyle: const TextStyle(fontSize: 17, color: KusdyColors.textoSecundario),
  helperStyle: const TextStyle(
    fontSize: 15,
    color: KusdyColors.textoSecundario,
  ),
  errorStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: KusdyColors.vencido,
  ),
  border: _borde(KusdyColors.bordeFuerte, 1.5),
  enabledBorder: _borde(KusdyColors.bordeFuerte, 1.5),
  focusedBorder: _borde(KusdyColors.primario, 2.5),
  errorBorder: _borde(KusdyColors.vencido, 1.5),
  focusedErrorBorder: _borde(KusdyColors.vencido, 2.5),
  disabledBorder: _borde(KusdyColors.borde, 1),
);
