import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/api/slide/self.dart' as slide_api;

class SlideBloc<T extends Slide> {
  String report;
  T initialSlide;
  void Function(T Function(T)) setSlide;

  SlideBloc({
    required this.report,
    required this.initialSlide,
    required this.setSlide,
  });

  Future<void> rename(String title) async {
    setSlide((slide) => slide..title = title);

    slide_api.renameSlide(
      report: report,
      slide: initialSlide.identifier,
      title: title,
    );
  }
}
