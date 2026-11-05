import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../productos/presentation/selector_producto.dart';
import '../domain/cliente.dart';
import '../domain/datos_cliente.dart';
import '../domain/validaciones_cliente.dart';

// Bocetos 5 y 6: el mismo formulario crea (cliente == null) y edita.
// No conoce Supabase: recibe la función que guarda.
class ClienteFormScreen extends StatefulWidget {
  const ClienteFormScreen({super.key, this.cliente, required this.alGuardar});

  final Cliente? cliente;
  final Future<void> Function(DatosCliente datos) alGuardar;

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cliente?.nombre);
  late final _telefono = TextEditingController(text: widget.cliente?.telefono);
  late final _direccion = TextEditingController(
    text: widget.cliente?.direccion,
  );
  late final _ciudad = TextEditingController(text: widget.cliente?.ciudad);
  late final _nota = TextEditingController(text: widget.cliente?.notaFija);
  late String? _productoId = widget.cliente?.productoId;
  int? _diasPrimeraLlamada = 1;
  var _guardando = false;
  String? _error;

  bool get _editando => widget.cliente != null;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _direccion, _ciudad, _nota]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final dias = _diasPrimeraLlamada;
    try {
      await widget.alGuardar(
        DatosCliente(
          nombre: _nombre.text,
          telefono: formatearTelefono(_telefono.text),
          direccion: _direccion.text,
          ciudad: _ciudad.text,
          notaFija: _nota.text,
          productoInteresId: _productoId,
          primeraLlamada: _editando || dias == null
              ? null
              : primeraLlamadaEn(dias),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _guardando = false;
        _error = e is ClienteException
            ? e.mensaje
            : 'No pudimos guardar. Revisa tu conexión e intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Nuevo cliente'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: Form(
        key: _form,
        // Columna completa (no ListView): todos los campos existen siempre,
        // así la validación marca también los que no se ven.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Campo(
                controller: _nombre,
                etiqueta: 'Nombre *',
                validator: validarNombre,
                capitalizar: TextCapitalization.words,
              ),
              _Campo(
                controller: _telefono,
                etiqueta: 'Teléfono *',
                validator: validarTelefono,
                teclado: TextInputType.phone,
              ),
              _Campo(controller: _direccion, etiqueta: 'Dirección'),
              _Campo(
                controller: _ciudad,
                etiqueta: 'Ciudad o municipio',
                capitalizar: TextCapitalization.words,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SelectorProducto(
                  valor: _productoId,
                  alCambiar: (id) => setState(() => _productoId = id),
                ),
              ),
              _Campo(
                controller: _nota,
                etiqueta: 'Nota fija (opcional)',
                lineas: 3,
              ),
              if (!_editando)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<int?>(
                    key: const Key('primera-llamada'),
                    initialValue: _diasPrimeraLlamada,
                    decoration: const InputDecoration(
                      labelText: 'Primera llamada',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      color: KusdyColors.texto,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Hoy')),
                      DropdownMenuItem(value: 1, child: Text('Mañana')),
                      DropdownMenuItem(value: 3, child: Text('En 3 días')),
                      DropdownMenuItem(value: 7, child: Text('En 1 semana')),
                      DropdownMenuItem(value: null, child: Text('Sin agendar')),
                    ],
                    onChanged: (v) => setState(() => _diasPrimeraLlamada = v),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: KusdyColors.vencido,
                      fontSize: 16,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _guardando
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.etiqueta,
    this.validator,
    this.teclado,
    this.capitalizar = TextCapitalization.sentences,
    this.lineas = 1,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final TextCapitalization capitalizar;
  final int lineas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: teclado,
        textCapitalization: capitalizar,
        maxLines: lineas,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
