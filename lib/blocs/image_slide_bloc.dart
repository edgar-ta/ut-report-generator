import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/response/edit_image_slide_response.dart';
import 'package:ut_report_generator/api/image_slide/self.dart' as image_slide;

class ImageSlideBloc {
  final String reportIdentifier;
  final ImageSlide initialImageSlide;
  final void Function(ImageSlide Function(ImageSlide imageSlide) callback)
  setImageSlide;

  ImageSlideBloc({
    required this.reportIdentifier,
    required this.initialImageSlide,
    required this.setImageSlide,
  });

  void _updateAfterEdition(EditImageSlide_Response response) {
    setImageSlide(
      (imageSlide) => imageSlide.copyWith(preview: response.preview),
    );
  }

  Future<void> editParameter(
    String parameterName,
    String parameterValue,
  ) async {
    setImageSlide(
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
          report: reportIdentifier,
          imageSlide: initialImageSlide.identifier,
          parameterName: parameterName,
          parameterValue: parameterValue,
        )
        .then(_updateAfterEdition);
  }
}
