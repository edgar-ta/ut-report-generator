import 'package:ut_report_generator/blocs/slide_bloc.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/response/edit_image_slide_response.dart';
import 'package:ut_report_generator/api/image_slide/self.dart' as image_slide;

class ImageSlideBloc extends SlideBloc<ImageSlide> {
  ImageSlideBloc({
    required super.report,
    required super.initialSlide,
    required super.setSlide,
  });

  void _updateAfterEdition(EditImageSlide_Response response) {
    setSlide((imageSlide) => imageSlide.copyWith(preview: response.preview));
  }

  Future<void> editParameter(
    String parameterName,
    String parameterValue,
  ) async {
    setSlide(
      (imageSlide) => imageSlide.copyWith(
        parameters:
            imageSlide.parameters..update(
              parameterName,
              (previousParameter) =>
                  previousParameter.copyWith(value: parameterValue),
            ),
      ),
    );
    await image_slide
        .editSlide(
          report: report,
          imageSlide: initialSlide.identifier,
          parameterName: parameterName,
          parameterValue: parameterValue,
        )
        .then(_updateAfterEdition);
  }
}
