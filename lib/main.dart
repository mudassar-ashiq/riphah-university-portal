import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/portal_repository.dart';
import 'theme.dart';
import 'widgets/glow_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UniversityPortalApp());
}

class UniversityPortalApp extends StatelessWidget {
  const UniversityPortalApp({super.key, this.authService, this.repository});

  /// Injectable services — tests pass fakes so no live Firebase is
  /// touched. In the real app the Firebase-backed defaults are used.
  final AuthService? authService;
  final PortalRepository? repository;

  @override
  Widget build(BuildContext context) {
    final auth = authService ?? FirebaseAuthService();
    final repo = repository ?? FirestorePortalRepository();
    return MaterialApp(
      title: 'Riphah University Portal',
      debugShowCheckedModeBanner: false,
      theme: buildRiphahTheme(),
      home: AuthGate(authService: auth, repository: repo),
    );
  }
}

/// Routes between the login screen and the portal shell based on the
/// Firebase sign-in state.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.repository,
  });

  final AuthService authService;
  final PortalRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: GlowBackground(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF003366)),
              ),
            ),
          );
        }
        final uid = snapshot.data;
        if (uid == null) {
          return AuthScreen(authService: authService, repository: repository);
        }
        return MainShell(
          uid: uid,
          authService: authService,
          repository: repository,
        );
      },
    );
  }
}
