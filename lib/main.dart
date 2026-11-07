import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'navigation/app_routes.dart';

import 'data/sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://heunbefkeflaaluvnxhv.supabase.co',
    publishableKey: 'sb_publishable_cjoixtoRF_PqSsp6_WVaWQ_gLgAsolG',
  );
  // Fetch sample data concurrently in background so UI opens instantly without delay
  SampleData.init();
  runApp(const LspApp());
}

class LspApp extends StatelessWidget {
  const LspApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSP Silver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkLuxuryTheme,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
