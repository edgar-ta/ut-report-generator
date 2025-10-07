import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

Future<StartReport_Response> startSlideshowWithPivotTable(
  List<String> dataFiles,
) {
  return sendRequest(
    route: "report/start_with_pivot_table",
    body: {"data_files": dataFiles},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef StartReport_Response = Slideshow;
