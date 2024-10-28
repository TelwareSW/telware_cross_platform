// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String BASE_URL = dotenv.env['BASE_URL']!;
final String GOOGLE_AUTH_URL = dotenv.env['GOOGLE_AUTH_URL']!;
final String FACEBOOK_AUTH_URL = dotenv.env['FACEBOOK_AUTH_URL']!;
final String GITHUB_AUTH_URL = dotenv.env['GITHUB_AUTH_URL']!;
final BASE_OPTIONS =
    BaseOptions(baseUrl: BASE_URL, contentType: 'application/json');
