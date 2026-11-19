import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdtscfpircwaubnknshn.supabase.co',
    publishableKey: 'sb_publishable_cjA6Nh946QdarmUkcLzwog_rDYMymq-',
  );

  runApp(const MyApp());
}

class _LocalizationGuard extends StatelessWidget {
  final Widget child;
  const _LocalizationGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'TaskFlow - Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: session != null ? '/home' : '/login',
      routes: {
        '/login': (context) => const _LocalizationGuard(child: LoginScreen()),
        '/register': (context) => const _LocalizationGuard(child: RegisterScreen()),
        '/home': (context) => const _LocalizationGuard(child: HomeScreen()),
      },
    );
  }
}
