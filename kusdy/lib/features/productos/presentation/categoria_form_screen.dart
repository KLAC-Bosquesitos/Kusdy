import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/categoria_producto.dart';

// El MISMO formulario crea y edita una categoría.
// - inicial == null: "Nueva categoría", botón "Crear".
// - inicial con datos: "Editar categoría", campos llenos, "Guardar cambios",
//   y además Archivar/Restaurar y Eliminar.
// No conoce Supabase ni providers: recibe funciones para guardar. Si una
// función lanza CategoriaException, muestra su mensaje y se queda abierto.
// Si todo sale bien, se cierra devolviendo el texto para el SnackBar.
class CategoriaFormScreen extends StatefulWidget {
  const CategoriaFormScreen({
    super.key,
    this.inicial,
    required this.onGuardar,
    this.onArchivar,
    this.onEliminar,
  });

  final CategoriaProducto? inicial;
  final Future<void> Function(String nombre) onGuardar;
  final Future<void> Function()? onArchivar;
  final Future<void> Function()? onEliminar;

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  late final _nombre = TextEditingController(text: widget.inicial?.nombre);
  bool _ocupado = false;
  String? _error;

  bool get _editando => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    // Para habilitar o deshabilitar el botón mientras se escribe.
    _nombre.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  // Corre una acción; si sale bien, cierra con el mensaje; si no, lo muestra.
  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    if (_ocupado) return;
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
      if (mounted) Navigator.of(context).pop(exito);
    } on CategoriaException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _eliminar() async {
    final nombre = widget.inicial!.nombre;
    final seguro = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: Text('Se eliminará "$nombre". Esto no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: KusdyColors.vencido),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (seguro != true) return;
    await _ejecutar(widget.onEliminar!, 'Se eliminó "$nombre".');
  }

  @override
  Widget build(BuildContext context) {
    final inicial = widget.inicial;
    final puedeGuardar = _nombre.text.trim().isNotEmpty && !_ocupado;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nombre,
            autofocus: !_editando,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej. Paneles solares',
            ),
          ),
          if (inicial != null) ...[
            const SizedBox(height: 12),
            Text(
              inicial.productos == 1
                  ? '1 producto en esta categoría.'
                  : '${inicial.productos} productos en esta categoría.',
              style: const TextStyle(
                fontSize: 16,
                color: KusdyColors.textoSecundario,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KusdyColors.vencidoSuave,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 16,
                  color: KusdyColors.vencido,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: puedeGuardar
                ? () => _ejecutar(
                    () => widget.onGuardar(_nombre.text),
                    _editando ? 'Cambios guardados.' : 'Categoría creada.',
                  )
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: Text(_editando ? 'Guardar cambios' : 'Crear'),
          ),
          if (inicial != null && widget.onArchivar != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _ocupado
                  ? null
                  : () => _ejecutar(
                      widget.onArchivar!,
                      inicial.archivada
                          ? 'Se restauró "${inicial.nombre}".'
                          : 'Se archivó "${inicial.nombre}".',
                    ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(inicial.archivada ? 'Restaurar' : 'Archivar'),
            ),
          ],
          if (inicial != null && widget.onEliminar != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: _ocupado ? null : _eliminar,
              style: TextButton.styleFrom(
                foregroundColor: KusdyColors.vencido,
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ],
      ),
    );
  }
}
