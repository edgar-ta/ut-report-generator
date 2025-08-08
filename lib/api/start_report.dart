import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/asset_type.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<StartReport_Response> startReport(String filename) {
  return sendRequest(
    route: "start_report",
    body: {"data_file": filename},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
class StartReport_Response {
  String reportDirectory;
  String reportName;

  // Properties of the first slide of the report
  List<AssetType> assets;
  String slideId;
  Map<String, dynamic> arguments;
  String preview;

  StartReport_Response({
    required this.reportDirectory,
    required this.reportName,
    required this.assets,
    required this.slideId,
    required this.arguments,
    required this.preview,
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
                  value: asset['value'] as String,
                  type: asset["type"] as String,
                ),
              )
              .toList(),
      slideId: json['slide_id'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      preview: json['preview'] as String,
    );
  }
}
