import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/models/report.dart';

// ignore: non_constant_identifier_names
Future<StartReport_Response> startReport_withImageSlide(ImageSlideKind kind) {
  return sendRequest(
    route: "report/start_with_image_slide",
    body: {"kind": kind.name},
    callback: StartReport_Response.fromJson,
  );
}

// ignore: camel_case_types
typedef StartReport_Response = ReportClass;
