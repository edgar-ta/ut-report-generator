import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/send_request.dart';

Future<http.Response> startReport(String filename) {
  return sendRequest(route: "start_report", body: {"data_file": filename});
}

// ignore: camel_case_types
class StartReport_Response {
  List<({String name, String path})> assets;
  String reportDirectory;
  String reportName;
  String sectionId;

  StartReport_Response({
    required this.assets,
    required this.reportDirectory,
    required this.reportName,
    required this.sectionId,
  });

  static StartReport_Response fromJson(Map<String, dynamic> json) {
    return StartReport_Response(
      assets:
          (json['assets'] as List<dynamic>)
              .map(
                (asset) => (
                  name: asset['name'] as String,
                  path: asset['path'] as String,
                ),
              )
              .toList(),
      reportDirectory: json['report_directory'] as String,
      reportName: json['report_name'] as String,
      sectionId: json['section_id'] as String,
    );
  }
}
