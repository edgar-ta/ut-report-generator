import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';

Future<ImageSlide> createImageSlide({
  required String report,
  required ImageSlideKind kind,
}) {
  return sendRequest(
    route: "image_slide/create",
    callback: ImageSlide.fromJson,
    body: {'report': report, 'kind': kind.name},
  );
}
