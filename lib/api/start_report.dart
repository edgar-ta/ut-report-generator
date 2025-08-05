import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/send_request.dart';

Future<http.Response> startReport(String filename) {
  return sendRequest(route: "start_report", body: {filename});
}

// ignore: camel_case_types
class StartReport_Response {
  String imagePath;
  String reportDirectory;
  String sectionId;

  StartReport_Response({
    required this.imagePath,
    required this.reportDirectory,
    required this.sectionId,
  });

  static StartReport_Response fromJson(Map<String, dynamic> json) {
    return StartReport_Response(
      imagePath: json['image_path'] as String,
      reportDirectory: json['report_directory'] as String,
      sectionId: json['section_id'] as String,
    );
  }
}
