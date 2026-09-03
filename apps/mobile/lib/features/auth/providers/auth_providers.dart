import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService.instance,
);

final authStateProvider = StreamProvider<bool>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.read(authServiceProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.read(authServiceProvider).currentUser;
});
