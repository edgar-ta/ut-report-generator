import 'package:flutter_dotenv/flutter_dotenv.dart';

String getEnvironmentVariable(String name, String defaultValue) {
  return dotenv.env[name] ?? defaultValue;
}
