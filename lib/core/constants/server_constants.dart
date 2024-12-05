// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_URL = dotenv.env['API_URL']!;
final String SOCKET_URL = dotenv.env['SOCKET_URL']!;
final String API_URL_PICTURES = dotenv.env['API_URL_PICTURES']!;
final String GOOGLE_AUTH_URL = API_URL + dotenv.env['GOOGLE_AUTH_URL']!;
final String GITHUB_AUTH_URL = API_URL + dotenv.env['GITHUB_AUTH_URL']!;
final int SOCKET_RECONNECT_DELAY_SECONDS =  int.parse(dotenv.env['SOCKET_RECONNECT_DELAY_SECONDS'] ?? '3');
final int EVENT_FAIL_LIMIT =  int.parse(dotenv.env['EVENT_FAIL_LIMIT'] ?? '5');

final BASE_OPTIONS = BaseOptions(
  baseUrl: API_URL,
  contentType: 'application/json',
  connectTimeout: const Duration(seconds: 5),
  // 5 seconds
  receiveTimeout: const Duration(seconds: 3),
  // 3 seconds
  sendTimeout: const Duration(seconds: 3), // 3 seconds
);

final CHAT_BASE_OPTIONS = BaseOptions(
  baseUrl: API_URL,
  contentType: 'application/json',
  connectTimeout: const Duration(seconds: 5),
  // 5 seconds
  receiveTimeout: const Duration(seconds: 100),
  // 3 seconds
  sendTimeout: const Duration(seconds: 100), // 3 seconds
);
