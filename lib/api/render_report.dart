import 'package:ut_report_generator/api/file_response.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<RenderReport_Response> renderReport({required String reportDirectory}) {
  return sendRequest(
    route: "render_report",
    body: {"report_directory": reportDirectory},
    callback: RenderReport_Response.fromJson,
  );
}

// ignore: camel_case_types
class RenderReport_Response implements FileResponse {
  @override
  String message;

  @override
  String outputFile;

  RenderReport_Response({required this.message, required this.outputFile});

  factory RenderReport_Response.fromJson(Map<String, dynamic> json) {
    return RenderReport_Response(
      message: json['message'] as String,
      outputFile: json['output_file'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'output_file': outputFile};
  }
}
