import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

Future<Slideshow> importReport({required String rootDirectory}) async {
  return sendRequest(
    route: "report/import",
    callback: Slideshow.fromJson,
    body: {"root_directory": rootDirectory},
  );
}
