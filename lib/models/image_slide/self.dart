import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/models/slide/self.dart';

class ImageSlide implements Slide {
  @override
  String identifier;

  ImageSlideKind kind;
  Map<String, dynamic> arguments;
  String preview;

  ImageSlide({
    required this.identifier,
    required this.kind,
    required this.arguments,
    required this.preview,
  });

  factory ImageSlide.fromJson(Map<String, dynamic> json) {
    return ImageSlide(
      identifier: json['id'] as String,
      kind: ImageSlideKind.values.byName(json['kind']),
      arguments: Map<String, dynamic>.from(json['arguments'] as Map),
      preview: json['preview'] as String,
    );
  }

  ImageSlide copyWith({
    String? identifier,
    ImageSlideKind? kind,
    Map<String, dynamic>? arguments,
    String? preview,
  }) {
    return ImageSlide(
      identifier: identifier ?? this.identifier,
      kind: kind ?? this.kind,
      arguments: arguments ?? Map<String, dynamic>.from(this.arguments),
      preview: preview ?? this.preview,
    );
  }
}
