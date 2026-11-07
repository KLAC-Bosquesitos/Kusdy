import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/productos_interes_repository_falso.dart';
import 'package:kusdy/features/productos/presentation/productos_interes_providers.dart';
import 'package:kusdy/core/utils/fechas.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/domain/resultado_llamada.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/hoy/presentation/hoy_screen.dart';

// Guarda lo que llega a registrarResultado para revisarlo.
class RepositorioEspia extends ActividadesRepositoryFalso {
  RepositorioEspia({super.modo}) : super(demora: Duration.zero);

  final registros = <RegistroLlamada>[];

  @override
  Future<void> registrarResultado(RegistroLlamada registro) async {
    await super.registrarResultado(registro);
    registros.add(registro);
  }
}

Widget hoyCon(ActividadesRepositoryFalso repositorio) {
  return ProviderScope(
    overrides: [
      actividadesRepositoryProvider.overrideWithValue(repositorio),
      productosInteresRepositoryProvider.overrideWithValue(
        ProductosInteresRepositoryFalso(),
      ),
    ],
    child: const MaterialApp(home: HoyScreen()),
  );
}

// Toca "Hecho" en la tarjeta del cliente.
Future<void> hecho(WidgetTester tester, String cliente) async {
  await tester.scrollUntilVisible(find.text(cliente), 200);
  final tarjeta = find.ancestor(
    of: find.text(cliente),
    matching: find.byType(Card),
  );
  final boton = find.descendant(of: tarjeta, matching: find.text('Hecho'));
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

Future<void> elegirProducto(WidgetTester tester, String nombre) async {
  await tester.ensureVisible(find.byKey(const Key('producto-interes')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('producto-interes')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(nombre).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Hoy: "Se te pasaron" va arriba, separado de hoy', (
    tester,
  ) async {
    await tester.pumpWidget(hoyCon(RepositorioEspia()));
    await tester.pumpAndSettle();

    expect(find.text('Se te pasaron (1)'), findsOne);
    expect(find.text('Hoy (4)'), findsOne);
    final vencida = tester.getTopLeft(find.text('Ana Gómez')).dy;
    final deHoy = tester.getTopLeft(find.text('María López')).dy;
    expect(vencida, lessThan(deHoy));
  });

  testWidgets('Hecho -> No contestó -> Mañana -> Guardar', (tester) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    expect(find.text('¿Qué pasó?'), findsOne);

    await tocar(tester, 'No contestó');
    expect(find.text('¿Cuándo vuelves a llamar?'), findsOne);
    await tester.enterText(
      find.byKey(const Key('comentario-llamada')),
      'Sonó y no contestó',
    );
    await tocar(tester, 'Guardar');

    final r = repositorio.registros.single;
    expect(r.actividadId, 'a1');
    expect(r.resultado, ResultadoLlamada.noContesto);
    expect(r.siguienteTipo, TipoActividad.llamada);
    final manana = DateTime.now().add(const Duration(days: 1));
    expect(mismoDia(r.siguienteFecha!, manana), isTrue);
    expect(r.comentario, 'Sonó y no contestó');

    // Volvió a Hoy, recargado: María ya no está pendiente hoy.
    expect(find.text('Listo: María López.'), findsOne);
    expect(find.text('María López'), findsNothing);
  });

  testWidgets('Le interesa -> elegir producto -> Guardar', (tester) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'Le interesa');
    await elegirProducto(tester, 'Calentador solar 200 L');
    await tocar(tester, 'Guardar');

    final r = repositorio.registros.single;
    expect(r.resultado, ResultadoLlamada.interesado);
    expect(r.productoInteresId, 'p200');
  });

  testWidgets('No contestó no pregunta el producto', (tester) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'No contestó');

    expect(find.byKey(const Key('producto-interes')), findsNothing);
    await tocar(tester, 'Guardar');
    expect(repositorio.registros.single.productoInteresId, isNull);
  });

  testWidgets('número equivocado no ofrece fecha', (tester) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'Carlos Méndez');
    await tocar(tester, 'Número equivocado');

    expect(find.text('Mañana'), findsNothing);
    await tocar(tester, 'Guardar');
    expect(repositorio.registros.single.siguienteFecha, isNull);
  });

  testWidgets('al entrar, cada resultado es un botón grande', (tester) async {
    await tester.pumpWidget(hoyCon(RepositorioEspia()));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');

    for (final r in ResultadoLlamada.values) {
      final boton = find.ancestor(
        of: find.text(r.texto),
        matching: find.byType(OutlinedButton),
      );
      expect(tester.getSize(boton).height, greaterThanOrEqualTo(64));
    }
    expect(find.text('Guardar'), findsNothing);
  });

  testWidgets('elegir colapsa los botones y deja solo el elegido', (
    tester,
  ) async {
    await tester.pumpWidget(hoyCon(RepositorioEspia()));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'No contestó');

    expect(find.text('No contestó'), findsOne);
    expect(find.text('Le interesa'), findsNothing);
    expect(find.text('Cambiar'), findsOne);
    expect(find.text('Guardar'), findsOne);
  });

  testWidgets('Cambiar corrige el resultado sin perder el comentario', (
    tester,
  ) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'No contestó');
    await tester.enterText(
      find.byKey(const Key('comentario-llamada')),
      'Quiere el de 200 L',
    );
    await tester.pumpAndSettle();

    await tocar(tester, 'Cambiar');
    expect(find.text('Guardar'), findsNothing);
    expect(find.text('¿Cuándo vuelves a llamar?'), findsNothing);

    await tocar(tester, 'Le interesa');
    expect(find.text('¿Cuándo le das seguimiento?'), findsOne);
    await tocar(tester, 'Guardar');

    final r = repositorio.registros.single;
    expect(r.resultado, ResultadoLlamada.interesado);
    expect(r.comentario, 'Quiere el de 200 L');
  });

  testWidgets('tocar el mismo resultado conserva la fecha elegida', (
    tester,
  ) async {
    final repositorio = RepositorioEspia();
    await tester.pumpWidget(hoyCon(repositorio));
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'No contestó');
    await tocar(tester, 'En 1 semana');
    await tocar(tester, 'Cambiar');
    await tocar(tester, 'No contestó');
    await tocar(tester, 'Guardar');

    final enUnaSemana = DateTime.now().add(const Duration(days: 7));
    final fecha = repositorio.registros.single.siguienteFecha!;
    expect(mismoDia(fecha, enUnaSemana), isTrue);
  });

  testWidgets('avisa cuando van 3 llamadas sin respuesta', (tester) async {
    await tester.pumpWidget(hoyCon(RepositorioEspia()));
    await tester.pumpAndSettle();

    await hecho(tester, 'Hotel Los Altos');

    expect(find.text('Van 3 llamadas sin respuesta.'), findsOne);
  });

  testWidgets('si falla al guardar, se queda y ofrece Reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(
      hoyCon(RepositorioEspia(modo: ModoAgenda.fallaBorrar)),
    );
    await tester.pumpAndSettle();

    await hecho(tester, 'María López');
    await tocar(tester, 'Le interesa');
    await tocar(tester, 'Guardar');

    expect(find.text('¿Qué pasó?'), findsOne);
    expect(find.text('No se pudo guardar. Revisa tu conexión.'), findsOne);
    expect(find.text('Reintentar'), findsOne);
  });

  testWidgets('Mover -> Mañana la quita de Hoy', (tester) async {
    await tester.pumpWidget(hoyCon(RepositorioEspia()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Carlos Méndez'), 200);
    final tarjeta = find.ancestor(
      of: find.text('Carlos Méndez'),
      matching: find.byType(Card),
    );
    final mover = find.descendant(of: tarjeta, matching: find.text('Mover'));
    await tester.ensureVisible(mover);
    await tester.pumpAndSettle();
    await tester.tap(mover);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mañana'));
    await tester.pumpAndSettle();

    expect(find.text('Carlos Méndez'), findsNothing);
    expect(find.textContaining('Movida al'), findsOne);
  });
}
