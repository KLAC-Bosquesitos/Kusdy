import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

// HU-01 · Iniciar sesión. Versión mínima: correo y contraseña. "Olvidé mi
// contraseña" y los menús por rol llegan en la fase 1.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocupado = false;
  bool _verContrasena = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_correo.text.trim().isEmpty || _contrasena.text.isEmpty) {
      setState(() => _error = 'Escribe tu correo y tu contraseña.');
      return;
    }
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .iniciarSesion(correo: _correo.text, contrasena: _contrasena.text);
      // No se navega a mano: la puerta de la app escucha la sesión y cambia
      // a la barra de pestañas sola.
    } on SesionException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 64,
                    color: KusdyColors.acento,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kusdy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: KusdyColors.primarioOscuro,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contrasena,
                    obscureText: !_verContrasena,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _entrar(),
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _verContrasena
                            ? 'Ocultar contraseña'
                            : 'Ver contraseña',
                        icon: Icon(
                          _verContrasena
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _verContrasena = !_verContrasena),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: KusdyColors.vencido,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _ocupado ? null : _entrar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _ocupado
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
