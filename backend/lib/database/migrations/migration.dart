import 'package:postgres/postgres.dart';

abstract class Migration {
  int get version;

  String get name;

  Future<void> up(TxSession session);
}