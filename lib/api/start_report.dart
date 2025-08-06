import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/send_request.dart';

Future<http.Response> startReport(String filename) {
  return sendRequest(route: "start_report", body: {"data_file": filename});
}

// ignore: camel_case_types
class StartReport_Response {
  String reportDirectory;
  String reportName;
  List<({String name, String path})> assets;
  String sectionId;
  dynamic arguments;

  StartReport_Response({
    required this.reportDirectory,
    required this.reportName,
    required this.assets,
    required this.sectionId,
    required this.arguments,
  });

  static StartReport_Response fromJson(Map<String, dynamic> json) {
    return StartReport_Response(
      reportDirectory: json['report_directory'] as String,
      reportName: json['report_name'] as String,
      assets:
          (json['assets'] as List<dynamic>)
              .map(
                (asset) => (
                  name: asset['name'] as String,
                  path: asset['path'] as String,
                ),
              )
              .toList(),
      sectionId: json['section_id'] as String,
      arguments: json['arguments'] as dynamic,
    );
  }
}
