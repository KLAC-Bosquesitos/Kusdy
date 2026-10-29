// Dónde está el Supabase de la app. Por defecto, el proyecto de desarrollo
// kusdy-dev. Para otro proyecto (por ejemplo producción) no se cambia el
// código: se corre con
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...
//
// La llave "publishable" puede ir en la app: es pública por diseño y lo que
// protege los datos es la seguridad por filas (RLS) de la base. La llave
// service_role NUNCA va en la app ni en el repositorio.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dygbykkhdnpuoapbkaip.supabase.co',
  );

  static const llavePublica = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_YaPNdRVLAVi4pybPUrrd4Q_M3gDXuWQ',
  );
}
