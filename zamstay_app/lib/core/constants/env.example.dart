class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qzgqkbemgoatiugoanrq.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6Z3FrYmVtZ29hdGl1Z29hbnJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NzAwMzIsImV4cCI6MjA5NzQ0NjAzMn0.RO3r6lXTSOs-jKF3iOzcEQR7HOAFe8NH-PgofoO0fG8',
  );
}
