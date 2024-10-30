// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

final USE_MOCK_DATA = (dotenv.env['USE_MOCK_DATA'] ?? 'false') == 'true';
