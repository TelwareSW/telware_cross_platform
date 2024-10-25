import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: non_constant_identifier_names
final String BASE_URL = dotenv.env['BASE_URL']!;
final BASE_OPTIONS =
    BaseOptions(baseUrl: BASE_URL, contentType: 'application/json');
