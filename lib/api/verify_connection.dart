import 'package:http/http.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<VerifyConnection_Response> verifyConnection() {
  return sendRequest(
    route: "hello",
    body: {"message": "Hello"},
    callback: VerifyConnection_Response.fromJson,
  );
}

// ignore: camel_case_types
class VerifyConnection_Response {
  String message;

  VerifyConnection_Response({required this.message});

  static VerifyConnection_Response fromJson(Map<String, dynamic> json) {
    return VerifyConnection_Response(message: json['message'] as String);
  }
}
