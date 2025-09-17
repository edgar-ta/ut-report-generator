import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class ImageSlide extends Slide {
  ImageSlideKind kind;
  Map<String, dynamic> parameters;

  ImageSlide({
    required super.identifier,
    required super.title,
    required super.creationDate,
    required super.lastEdit,
    required super.preview,
    required this.kind,
    required this.parameters,
  }) : super(category: SlideCategory.imageSlide);

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), 'kind': kind.name, 'parameters': parameters};
  }

  factory ImageSlide.fromJson(Map<String, dynamic> json) {
    return ImageSlide(
      identifier: json["identifier"],
      title: json["title"],
      creationDate: DateTime.parse(json["creation_date"]),
      lastEdit: DateTime.parse(json["last_edit"]),
      preview: json["preview"],
      kind: ImageSlideKind.values.byName(json["kind"]),
      parameters: json["parameters"],
    );
  }
}
