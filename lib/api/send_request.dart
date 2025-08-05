import 'package:http/http.dart' as http;
import 'package:ut_report_generator/control_variables.dart';

Future<http.Response> sendRequest({required String route, Object? body}) {
  return http
      .post(Uri.parse("http://localhost:$SERVER_PORT/$route"), body: body)
      .then((response) {
        if (response.statusCode == 200) {
          print("Request successful: ${response.body}");
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
        return response;
      })
      .catchError((error) {
        print("Error occurred: $error");
        throw error;
      });
}
