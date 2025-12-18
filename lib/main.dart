import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/job_provider.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated file by flutterfire CLI
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

// --- Initialization Function for Guaranteed Order ---
Future<void> initializeApp() async {
  // 1. Initialize DIO first (synchronous). This must happen before any providers are created.
  AuthService.initializeDio();
  print("Dio initialized with JWT Interceptor.");

  // 2. Await Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
// ----------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL FIX: AWAIT the setup function to ensure DIO and Firebase are ready
  await initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
          create: (_) => JobProvider(),
          update: (_, authProvider, jobProvider) {
            jobProvider!.updateUser(authProvider.user?.uid);
            return jobProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Decide which screen to show
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return const HomeScreen(); // logged in
    } else {
      return LoginScreen(); // not logged in
    }
  }
}
