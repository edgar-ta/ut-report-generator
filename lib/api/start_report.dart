import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/types/report_class.dart';

Future<StartReport_Response> startReport(List<String> dataFiles) {
  return sendRequest(
    route: "start_report",
    body: {"data_files": dataFiles},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef StartReport_Response = ReportClass;
