import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

Future<Slideshow> importSlideshow({required String reportFile}) async {
  return sendRequest(
    route: "report/import",
    callback: Slideshow.fromJson,
    body: {"report_file": reportFile},
  );
}
