import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

// ignore: non_constant_identifier_names
Future<StartReport_Response> startReport_withPivotTable(
  List<String> dataFiles,
) {
  return sendRequest(
    route: "report/start_with_pivot_table",
    body: {"data_files": dataFiles},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef StartReport_Response = ReportClass;
