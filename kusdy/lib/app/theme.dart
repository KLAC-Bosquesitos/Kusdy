import 'package:flutter/material.dart';

// Los estilos de botones, chips y barra no heredan la letra del tema: se
// repite para que no caigan en Roboto.
const fuenteKusdy = 'AtkinsonHyperlegible';

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
  static const vencidoBorde = Color(0xFFF0B8B3);
  static const exito = Color(0xFF1F6B3A);
  static const exitoSuave = Color(0xFFE3F2E8);
  static const aviso = Color(0xFF8A5A00);
  static const avisoSuave = Color(0xFFFFF4E5);
}

// Estilo de los diseños "Kusdy pantallas": letra Atkinson Hyperlegible
// (hecha para baja visión), tarjetas blancas sin borde sobre fondo gris y
// botones de 50 px con esquinas de 12.
final kusdyTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fuenteKusdy,
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
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 17, height: 1.4),
    bodyMedium: TextStyle(fontSize: 16, height: 1.4),
  ).apply(bodyColor: KusdyColors.texto, displayColor: KusdyColors.texto),
  appBarTheme: const AppBarTheme(
    backgroundColor: KusdyColors.fondo,
    foregroundColor: KusdyColors.texto,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: 72,
    titleTextStyle: TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: KusdyColors.texto,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: KusdyColors.superficie,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  filledButtonTheme: FilledButtonThemeData(style: _boton()),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: _boton().copyWith(
      backgroundColor: const WidgetStatePropertyAll(KusdyColors.superficie),
      foregroundColor: const WidgetStatePropertyAll(KusdyColors.texto),
      side: const WidgetStatePropertyAll(
        BorderSide(color: KusdyColors.bordeFuerte, width: 1.5),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: KusdyColors.primario,
      minimumSize: const Size(48, 48),
      textStyle: const TextStyle(
        fontFamily: fuenteKusdy,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: KusdyColors.acento,
    foregroundColor: KusdyColors.texto,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: KusdyColors.superficie,
    selectedColor: KusdyColors.primarioOscuro,
    checkmarkColor: Colors.white,
    side: WidgetStateBorderSide.resolveWith(
      (estados) => BorderSide(
        color: estados.contains(WidgetState.selected)
            ? KusdyColors.primarioOscuro
            : KusdyColors.bordeFuerte,
        width: 1.5,
      ),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    labelStyle: const TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 16,
      color: KusdyColors.texto,
    ),
    secondaryLabelStyle: const TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: KusdyColors.superficie,
    surfaceTintColor: Colors.transparent,
    indicatorColor: KusdyColors.acentoSuave,
    height: 72,
    labelTextStyle: WidgetStateTextStyle.resolveWith(
      (estados) => TextStyle(
        fontFamily: fuenteKusdy,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: estados.contains(WidgetState.selected)
            ? KusdyColors.texto
            : KusdyColors.textoSecundario,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (estados) => IconThemeData(
        color: estados.contains(WidgetState.selected)
            ? KusdyColors.acentoTexto
            : KusdyColors.textoSecundario,
      ),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: KusdyColors.superficie,
    surfaceTintColor: Colors.transparent,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: KusdyColors.superficie,
    surfaceTintColor: Colors.transparent,
    headerBackgroundColor: KusdyColors.primarioOscuro,
    headerForegroundColor: Colors.white,
    todayBorder: const BorderSide(color: KusdyColors.primario, width: 1.5),
    dayBackgroundColor: WidgetStateProperty.resolveWith(
      (estados) => estados.contains(WidgetState.selected)
          ? KusdyColors.primarioOscuro
          : null,
    ),
  ),
  dividerTheme: const DividerThemeData(color: KusdyColors.borde, space: 1),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(fontFamily: fuenteKusdy, fontSize: 16),
  ),
  inputDecorationTheme: _camposDeFormulario,
);

ButtonStyle _boton() => ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(48, 50)),
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  textStyle: const WidgetStatePropertyAll(
    TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  ),
);

// Botón naranja, para la única acción de marca por pantalla (texto oscuro).
final botonAcento = FilledButton.styleFrom(
  backgroundColor: KusdyColors.acento,
  foregroundColor: KusdyColors.texto,
  minimumSize: const Size.fromHeight(54),
);

// Campos de formulario más legibles (pedido de Freddy y Amilcar).
// La etiqueta flotante se dibuja al 75 %, por eso va en 22.
Color _colorEtiqueta(Set<WidgetState> estados) {
  if (estados.contains(WidgetState.error)) return KusdyColors.vencido;
  if (estados.contains(WidgetState.focused)) return KusdyColors.primario;
  return KusdyColors.primarioOscuro;
}

OutlineInputBorder _borde(Color color, double grosor) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: color, width: grosor),
);

final _camposDeFormulario = InputDecorationTheme(
  filled: true,
  fillColor: KusdyColors.superficie,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  labelStyle: WidgetStateTextStyle.resolveWith(
    (estados) => TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: estados.contains(WidgetState.error)
          ? KusdyColors.vencido
          : KusdyColors.textoSecundario,
    ),
  ),
  floatingLabelStyle: WidgetStateTextStyle.resolveWith(
    (estados) => TextStyle(
      fontFamily: fuenteKusdy,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _colorEtiqueta(estados),
    ),
  ),
  hintStyle: const TextStyle(
    fontFamily: fuenteKusdy,
    fontSize: 17,
    color: KusdyColors.textoSecundario,
  ),
  helperStyle: const TextStyle(
    fontFamily: fuenteKusdy,
    fontSize: 15,
    color: KusdyColors.textoSecundario,
  ),
  errorStyle: const TextStyle(
    fontFamily: fuenteKusdy,
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
