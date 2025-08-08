import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ut_report_generator/control_variables.dart';

Future<K> sendRequest<K>({
  required String route,
  required K Function(Map<String, dynamic>) callback,
  Object? body,
}) {
  print("@send_request.dart");
  print("Sending data to route: $route");
  print(jsonEncode(body));

  return http
      .post(
        Uri.parse("http://localhost:5000/$route"),
        // Uri.parse("http://localhost:$SERVER_PORT/$route"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      )
      .then((response) {
        if (response.statusCode == 200) {
          print("@send_request.dart");
          print("Request successful: ${response.body}");
        } else {
          print("@send_request.dart");
          print("Request failed with status: ${response.statusCode}");
          throw Exception(response.body);
        }
        return callback.call(jsonDecode(response.body));
      })
      .catchError((error) {
        print("@send_request.dart");
        print("Error occurred: $error");
        throw error;
      });
}
