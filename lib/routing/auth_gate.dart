import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../routing/app_routes.dart';
import '../screens/auth.dart';
import '../screens/onboarding.dart';
import '../screens/role_select.dart';
import 'student_shell.dart';
import 'tutor_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthStatus status = context.select<AuthProvider, AuthStatus>(
      (AuthProvider provider) => provider.status,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    if (status == AuthStatus.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (status == AuthStatus.unauthenticated) {
      return Navigator(
        initialRoute: '/onboarding',
        onGenerateInitialRoutes: (navigator, initialRoute) => [
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        ],
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/onboarding':
              return MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              );
            case AppRoutes.auth:
              return MaterialPageRoute(builder: (_) => const AuthScreen());
            default:
              throw Exception('Unknown route in auth flow: ${settings.name}');
          }
        },
      );
    }
    if (user == null || user.role == null) {
      return const RoleSelectScreen();
    }
    return switch (user.role!) {
      UserRole.student => const StudentShell(),
      UserRole.tutor => const TutorShell(),
    };
  }
}
