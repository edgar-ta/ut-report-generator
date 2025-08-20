import 'package:ut_report_generator/api/render_report.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<ExportReport_Response> exportReport({required String reportDirectory}) {
  return sendRequest(
    route: "export_report",
    body: {"report_directory": reportDirectory},
    callback: ExportReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef ExportReport_Response = RenderReport_Response;
