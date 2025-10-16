// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:club_hub/firebase_options.dart';
import 'package:club_hub/src/core/theme/app_theme.dart';
import 'package:club_hub/src/features/auth/presentation/screens/login_screen.dart';
import 'package:club_hub/src/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ClubHubApp()));
}

class ClubHubApp extends ConsumerWidget {
  const ClubHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Club Hub',
      // Forzamos el tema "SetPoint" dark para toda la app
      theme: AppTheme.setpointDark(),
      darkTheme: AppTheme.setpointDark(),
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
      builder: (context, child) {
        // Igual que SetPoint HQ: bloquea escalado de texto para consistencia UI
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
