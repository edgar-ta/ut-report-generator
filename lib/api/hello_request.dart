import 'package:ut_report_generator/api/send_request.dart';

Future<HelloRequest_Response> helloRequest() {
  return sendRequest(
    route: "hello",
    body: {"message": "Hello"},
    callback: HelloRequest_Response.fromJson,
  );
}

// ignore: camel_case_types
class HelloRequest_Response {
  String message;

  HelloRequest_Response({required this.message});

  static HelloRequest_Response fromJson(Map<String, dynamic> json) {
    return HelloRequest_Response(message: json['message'] as String);
  }
}
