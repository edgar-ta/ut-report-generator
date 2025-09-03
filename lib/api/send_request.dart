import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ut_report_generator/utils/control_variables.dart';

Future<K> sendRequest<K>({
  required String route,
  required K Function(Map<String, dynamic>) callback,
  Object? body,
  int retries = 3, // número de reintentos si NO hay respuesta
}) async {
  int attempt = 0;
  http.Response? response = null;

  print("@send_request.dart");
  print("Sending data to route: $route");
  print(jsonEncode(body));

  while (true) {
    try {
      response = await http
          .post(
            Uri.parse("http://localhost:${serverPort()}/$route"),
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      break;
    } catch (error) {
      attempt++;
      if (attempt >= retries) {
        print("Error after $attempt attempts: $error");
        rethrow;
      }
      print("Retry #${attempt - 1}");
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  if (response.statusCode != 200) {
    print("Request failed with status ${response.statusCode}");
  }

  return callback(jsonDecode(response.body));
}
