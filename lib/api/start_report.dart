import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/types/report_class.dart';

Future<StartReport_Response> startReport(String filename) {
  return sendRequest(
    route: "start_report",
    body: {"data_file": filename},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef StartReport_Response = ReportClass;
