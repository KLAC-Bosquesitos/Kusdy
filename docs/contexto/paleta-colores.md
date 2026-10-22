# Kusdy · Paleta de colores

> Basada en el logo de Energica Solar (naranja + azul). Los valores de marca se tomaron directamente de los píxeles del logo.
> Estado: **Propuesta** (2026-10-05). Contrastes medidos con la fórmula WCAG; el mínimo para texto normal es **4.5:1**.

---

## 1. Colores de marca (del logo)

| Nombre | Hex | Dónde aparece en el logo |
|---|---|---|
| Naranja Energica | `#FD6512` | El círculo naranja |
| Naranja claro | `#FE782F` | Centro del círculo (brillo) |
| Azul Energica | `#1E5BC5` | Fondo azul, parte clara |
| Azul profundo | `#1E4180` | Fondo azul, parte oscura |

---

## 2. Paleta de la app

### Marca y acciones

| Token | Hex | Uso | Contraste |
|---|---|---|---|
| `primario` | `#1E5BC5` | Botones principales (Llamar, Guardar), enlaces, pestaña activa | blanco encima: 6.25:1 ✅ |
| `primarioOscuro` | `#1E4180` | Encabezados, texto de títulos, botón presionado | blanco encima: 9.89:1 ✅ |
| `primarioSuave` | `#E8F0FC` | Fondo de chips y avatares azules | texto `#1E4180` encima: 8.62:1 ✅ |
| `acento` | `#FD6512` | Botón flotante "Registrar", detalles de marca | **solo con texto oscuro** `#15212A`: 5.49:1 ✅ · blanco encima: 2.98:1 ❌ |
| `acentoTexto` | `#B84A0A` | Naranja cuando tiene que ser texto sobre blanco | 5.22:1 ✅ |
| `acentoSuave` | `#FFEDE3` | Fondo suave naranja (pestaña activa, resaltados) | `#B84A0A` encima: 4.59:1 ✅ |

### Neutros (grises con un toque azul, para que combinen con la marca)

| Token | Hex | Uso |
|---|---|---|
| `fondo` | `#F5F7FA` | Fondo de las pantallas |
| `superficie` | `#FFFFFF` | Tarjetas, listas, hojas inferiores |
| `texto` | `#15212A` | Texto principal |
| `textoSecundario` | `#4B5A6E` | Descripciones, fechas (7.03:1 sobre blanco ✅) |
| `borde` | `#D5DCE6` | Bordes de campos y separadores |
| `bordeFuerte` | `#A9B4C6` | Borde de botones secundarios |

### Estados (significado, no decoración)

| Token | Hex | Fondo suave | Uso |
|---|---|---|---|
| `vencido` | `#B3261E` | `#FDECEA` | Actividades que ya se pasaron (6.54:1 ✅) |
| `exito` | `#1F6B3A` | `#E3F2E8` | Cliente ganado, actividad completada (6.52:1 ✅) |
| `aviso` | `#8A5A00` | `#FFF4E5` | Cliente sin seguimiento programado (5.45:1 ✅) |

---

## 3. Reglas de uso

1. **El naranja nunca lleva texto blanco.** Con blanco el contraste es 2.98:1 y a Freddy (61 años) le costaría leerlo. Sobre naranja, el texto va en `texto` (#15212A).
2. **El naranja es para "hacer", el rojo es para "se te pasó".** Como naranja y rojo se parecen, el naranja se reserva para *una* acción por pantalla (el botón "Registrar") y nunca para estados. Lo vencido además lleva ícono y texto ("Vencía ayer"), no solo color.
3. **El azul es el color de trabajo.** Botones principales, enlaces y la pestaña activa. Así la app se siente de Energica sin que todo sea naranja.
4. **Los estados no dependen solo del color.** Siempre van con palabra o ícono (por si hay daltonismo o pantalla con sol).
5. **Fondo gris muy claro + tarjetas blancas.** Separa los bloques sin tener que dibujar bordes en todo.

---

## 4. Cómo llevarlo a Flutter

```dart
// lib/app/theme.dart
import 'package:flutter/material.dart';

class KusdyColors {
  static const primario        = Color(0xFF1E5BC5);
  static const primarioOscuro  = Color(0xFF1E4180);
  static const primarioSuave   = Color(0xFFE8F0FC);
  static const acento          = Color(0xFFFD6512);
  static const acentoTexto     = Color(0xFFB84A0A);
  static const acentoSuave     = Color(0xFFFFEDE3);

  static const fondo           = Color(0xFFF5F7FA);
  static const superficie      = Color(0xFFFFFFFF);
  static const texto           = Color(0xFF15212A);
  static const textoSecundario = Color(0xFF4B5A6E);
  static const borde           = Color(0xFFD5DCE6);
  static const bordeFuerte     = Color(0xFFA9B4C6);

  static const vencido         = Color(0xFFB3261E);
  static const vencidoSuave    = Color(0xFFFDECEA);
  static const exito           = Color(0xFF1F6B3A);
  static const exitoSuave      = Color(0xFFE3F2E8);
  static const aviso           = Color(0xFF8A5A00);
  static const avisoSuave      = Color(0xFFFFF4E5);
}

final kusdyTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: KusdyColors.fondo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: KusdyColors.primario,
    primary: KusdyColors.primario,
    onPrimary: Colors.white,
    secondary: KusdyColors.acento,
    onSecondary: KusdyColors.texto, // texto oscuro sobre naranja
    error: KusdyColors.vencido,
    surface: KusdyColors.superficie,
    onSurface: KusdyColors.texto,
  ),
);
```

**Por qué una clase con constantes:** si mañana Energica ajusta su naranja, lo cambias en un solo lugar y toda la app se actualiza. Nunca escribas `Color(0xFF...)` suelto dentro de una pantalla.

---

## 5. Modo oscuro (para más adelante)

No es prioridad para la primera versión. Si se agrega, punto de partida: fondo `#0F1726`, superficie `#1A2333`, texto `#E6EAF2`, texto secundario `#A9B4C6`, primario `#7EA6F0`, acento `#FD6512` (sobre fondo oscuro sí se lee: 6.02:1), vencido `#FF8A80`.
