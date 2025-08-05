import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/send_request.dart';

Future<http.Response> startReport(String filename) {
  return sendRequest(route: "start_report", body: {"filename": filename});
}

// ignore: camel_case_types
class StartReport_Response {
  String imagePath;
  String reportDirectory;
  String reportName;
  String sectionId;

  StartReport_Response({
    required this.imagePath,
    required this.reportDirectory,
    required this.reportName,
    required this.sectionId,
  });

  static StartReport_Response fromJson(Map<String, dynamic> json) {
    return StartReport_Response(
      imagePath: json['image_path'] as String,
      reportDirectory: json['report_directory'] as String,
      reportName: json['report_name'] as String,
      sectionId: json['section_id'] as String,
    );
  }
}
