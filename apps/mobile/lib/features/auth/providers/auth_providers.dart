import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authServiceProvider = Provider<AuthService>(
  (ref) {
    return AuthService(
      ref.read(supabaseClientProvider),
    );
  },
);

final authStateProvider = StreamProvider<AuthState>(
  (ref) {
    return ref
        .read(authServiceProvider)
        .authStateChanges;
  },
);