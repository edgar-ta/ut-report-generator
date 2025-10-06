import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/hello_request_response.dart';

Future<HelloRequestResponse> helloRequest() {
  return sendRequest(
    route: "hello",
    body: {"message": "Hello"},
    callback: HelloRequestResponse.fromJson,
  );
}
