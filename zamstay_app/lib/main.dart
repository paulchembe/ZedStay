import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://supabase.com/dashboard/project/qzgqkbemgoatiugoanrq/settings/api-keys',
    anonKey: 'sb_publishable_LowXDlxcrXLnBTEAwp9D_Q_DzIc0t5E',
  );

  runApp(const ProviderScope(child: ZamStayApp()));
}