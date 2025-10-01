import 'package:ut_report_generator/models/report/self.dart';

class SlideshowEditorRequest {
  Future<Slideshow> Function() startCallback;
  Future<void> Function() callbackWhenReturning;

  SlideshowEditorRequest({
    required this.startCallback,
    required this.callbackWhenReturning,
  });
}
