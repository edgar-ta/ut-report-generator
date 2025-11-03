import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ut_report_generator/utils/control_variables.dart';

Future<K> sendRequest<K>({
  required String route,
  required K Function(Map<String, dynamic>) callback,
  Object? body,
  int retries = 3,
}) async {
  int attempt = 0;
  http.Response? response;

  print("@send_request.dart");
  print(
    "Sending data to route '$route' on port ${ControlVariables.instance.serverPort}",
  );
  print(jsonEncode(body));

  while (true) {
    try {
      response = await http
          .post(
            Uri(
              port: ControlVariables.instance.serverPort,
              scheme: "http",
              host: "localhost",
              path: "/$route",
            ),
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

  print("Successful request");
  print(response.body);

  return callback(jsonDecode(response.body));
}
