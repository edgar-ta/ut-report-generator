import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

Future<ChangeVisualizationMode_Response> changeVisualizationMode({
  required String report,
  required String pivotTable,
  required SlideCategory mode,
}) {
  return sendRequest(
    route: "pivot_table/change_visualization_mode",
    callback: ChangeVisualizationMode_Response.fromJson,
    body: {"report": report, "pivot_table": pivotTable, "mode": mode.name},
  );
}

// ignore: camel_case_types
class ChangeVisualizationMode_Response {
  String preview;

  ChangeVisualizationMode_Response({required this.preview});

  factory ChangeVisualizationMode_Response.fromJson(Map<String, dynamic> json) {
    return ChangeVisualizationMode_Response(preview: json['preview']);
  }
}
