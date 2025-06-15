import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://rytrsmizujhkcegxabzv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5dHJzbWl6dWpoa2NlZ3hhYnp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMTk5NjAsImV4cCI6MjA2NTU5NTk2MH0.yhVFdIcET2RyU7Z_r6td2N4emkQL3cpBX1B9UWXLNOM',
  );
  
  runApp(
    const ProviderScope(
      child: BMITrackerApp(),
    ),
  );
}

class BMITrackerApp extends ConsumerWidget {
  const BMITrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}