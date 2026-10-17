import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope guarda el estado de todos los providers de la app.
  runApp(const ProviderScope(child: KusdyApp()));
}
