import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../providers/auth_providers.dart';
import 'screens/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const LoginScreen(),
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const AppShell();
        }

        return const LoginScreen();
      },
    );
  }
}
