import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report/self.dart';

Future<Slideshow> startSlideshowWithImageSlide() {
  return sendRequest(
    route: "report/start_with_image_slide",
    callback: Slideshow.fromJson,
  );
}
