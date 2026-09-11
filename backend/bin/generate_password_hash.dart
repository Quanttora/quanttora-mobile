import 'package:backend/services/auth/password_hash_service.dart';

Future<void> main() async {
  final hash = await PasswordHashService.hash('Priya@9395');
  print(hash);
}
