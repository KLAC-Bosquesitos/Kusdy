import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/supabase/supabase_config.dart';

Future<void> main() async {
  // Supabase.initialize usa plugins (guarda la sesión en el teléfono), y los
  // plugins necesitan que Flutter esté listo antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // No se conecta a internet: solo prepara el cliente y lee la sesión que
  // haya quedado guardada. La app abre aunque no haya señal.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.llavePublica,
  );
  // ProviderScope guarda el estado de todos los providers de la app.
  runApp(const ProviderScope(child: KusdyApp()));
}
