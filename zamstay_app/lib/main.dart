import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Supabase.initialize(
    url: 'https://qzgqkbemgoatiugoanrq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6Z3FrYmVtZ29hdGl1Z29hbnJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NzAwMzIsImV4cCI6MjA5NzQ0NjAzMn0.RO3r6lXTSOs-jKF3iOzcEQR7HOAFe8NH-PgofoO0fG8',
    debug:true,
  );

  runApp(const ProviderScope(child: ZamStayApp()));
}