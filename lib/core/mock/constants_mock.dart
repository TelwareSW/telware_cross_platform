// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

final USE_MOCK_DATA = (dotenv.env['USE_MOCK_DATA'] ?? 'false') == 'true';
final USE_MOCK_DATA_STORIES =
    (dotenv.env['USE_MOCK_DATA_STORIES'] ?? 'true') == 'false';
final UPLOAD_MEDIA = (dotenv.env['UPLOAD_MEDIA'] ?? 'false') == 'true';
