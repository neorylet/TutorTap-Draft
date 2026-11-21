import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/classroom_provider.dart';
import 'providers/study_provider.dart';
import 'routing/app_routes.dart';
import 'routing/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/cloudinary_service.dart';
import 'services/firestore_service.dart';
import 'services/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    runApp(FirebaseErrorScreen(error: e.toString()));
    return;
  }

  if (const bool.fromEnvironment('ENABLE_TUTORTAP_SEED', defaultValue: false)) {
    await SeedService().seedAll();
  }

  final AuthProvider authProvider = AuthProvider(AuthService());
  authProvider.initialize();

  runApp(TutorTapApp(authProvider: authProvider));
}

class TutorTapApp extends StatelessWidget {
  const TutorTapApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final CloudinaryService cloudinaryService = CloudinaryService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(firestoreService),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(firestoreService),
        ),
        ChangeNotifierProvider<ClassroomProvider>(
          create: (_) => ClassroomProvider(firestoreService, cloudinaryService),
        ),
        ChangeNotifierProvider<StudyProvider>(
          create: (_) => StudyProvider(firestoreService),
        ),
      ],
      child: MaterialApp(
        title: 'TutorTap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        home: const AuthGate(),
      ),
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your google-services.json configuration and try again.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
