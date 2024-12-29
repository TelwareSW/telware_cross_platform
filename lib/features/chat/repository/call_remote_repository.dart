import 'package:dio/dio.dart';

class CallRemoteRepository {
  final Dio _dio;

  CallRemoteRepository({required Dio dio}) : _dio = dio;
}
