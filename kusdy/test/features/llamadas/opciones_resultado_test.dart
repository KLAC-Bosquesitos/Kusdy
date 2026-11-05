import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/domain/resultado_llamada.dart';
import 'package:kusdy/features/llamadas/domain/opciones_resultado.dart';

void main() {
  test('no contestó: volver a llamar mañana', () {
    final o = opcionesPara(ResultadoLlamada.noContesto);
    expect(o.tipo, TipoActividad.llamada);
    expect(o.dias, 1);
    expect(o.pideFecha, isTrue);
  });

  test('agendó visita y compró sugieren visita e instalación', () {
    expect(
      opcionesPara(ResultadoLlamada.agendoVisita).tipo,
      TipoActividad.visita,
    );
    expect(
      opcionesPara(ResultadoLlamada.compro).tipo,
      TipoActividad.instalacion,
    );
  });

  test('no le interesa: se puede volver a intentar, sin fecha por defecto', () {
    final o = opcionesPara(ResultadoLlamada.noInteresado);
    expect(o.pideFecha, isTrue);
    expect(o.dias, isNull);
  });

  test('número equivocado y no volver a llamar cierran el seguimiento', () {
    expect(opcionesPara(ResultadoLlamada.numeroEquivocado).pideFecha, isFalse);
    expect(opcionesPara(ResultadoLlamada.noVolverALlamar).pideFecha, isFalse);
  });

  test('fechaConAtajo: cruza de mes y conserva la hora', () {
    final ahora = DateTime(2026, 11, 29, 18, 45);
    expect(fechaConAtajo(3, ahora), DateTime(2026, 12, 2, 9));
    expect(
      fechaConAtajo(1, ahora, horaDe: DateTime(2026, 11, 20, 15, 30)),
      DateTime(2026, 11, 30, 15, 30),
    );
  });
}
