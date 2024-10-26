
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logInTypeProvider = StateProvider<LogInType?>((ref) {
  return null;
});

enum LogInType {
  email('email'),
  google('google'),
  facebook('facebook'),
  github('github');

  final String name;

  const LogInType(this.name);
}