import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

// ignore: non_constant_identifier_names
Future<ReportClass> startReport_withImageSlide() {
  return sendRequest(
    route: "report/start_with_image_slide",
    callback: ReportClass.fromJson,
  );
}
