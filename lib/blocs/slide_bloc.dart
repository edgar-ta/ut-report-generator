import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/api/slide/self.dart' as slide_api;

class SlideBloc<T extends Slide> {
  String slideshow;
  T initialSlide;
  void Function(T Function(T)) setSlide;

  SlideBloc({
    required this.slideshow,
    required this.initialSlide,
    required this.setSlide,
  });

  Future<void> rename(String title) async {
    setSlide((slide) => slide..title = title);

    slide_api.renameSlide(
      report: slideshow,
      slide: initialSlide.identifier,
      title: title,
    );
  }
}
