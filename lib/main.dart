import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY']?.trim();

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw StateError('SUPABASE_URL is missing from .env');
  }

  if (supabasePublishableKey == null || supabasePublishableKey.isEmpty) {
    throw StateError('SUPABASE_PUBLISHABLE_KEY is missing from .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const ProviderScope(child: QuanttoraApp()));
}
