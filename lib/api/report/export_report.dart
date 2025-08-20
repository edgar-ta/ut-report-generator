import 'package:ut_report_generator/api/report/render_report.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<ExportReport_Response> exportReport({required String identifier}) {
  return sendRequest(
    route: "report/export",
    body: {"report": identifier},
    callback: ExportReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef ExportReport_Response = RenderReport_Response;
