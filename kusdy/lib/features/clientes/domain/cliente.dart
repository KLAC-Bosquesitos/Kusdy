import 'datos_cliente.dart';

// Cliente o prospecto. Los campos salen de la vista clientes_resumen.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.registradoEl,
    this.producto,
    this.direccion,
    this.ciudad,
    this.notaFija,
    this.ultimoContacto,
    this.proximaLlamada,
    this.noContesto = false,
    this.intentosSinRespuesta = 0,
  });

  final String id;
  final String nombre;
  final String telefono;
  final DateTime registradoEl;
  final String? producto;
  final String? direccion;
  final String? ciudad;
  final String? notaFija;
  final DateTime? ultimoContacto;
  final DateTime? proximaLlamada;

  // La última llamada fue "no contestó" (filtro que pidió Fredy).
  final bool noContesto;
  final int intentosSinRespuesta;

  // Lo que el formulario puede editar.
  DatosCliente get datos => DatosCliente(
    nombre: nombre,
    telefono: telefono,
    direccion: direccion,
    ciudad: ciudad,
    notaFija: notaFija,
  );
}
