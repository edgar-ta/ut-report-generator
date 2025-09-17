import 'package:ut_report_generator/models/slide_category.dart';

class Slide {
  String identifier;
  String title;
  DateTime creationDate;
  DateTime lastEdit;
  String preview;
  SlideCategory category;

  Slide({
    required this.identifier,
    required this.title,
    required this.creationDate,
    required this.lastEdit,
    required this.preview,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "identifier": identifier,
      "creation_date": creationDate.toIso8601String(),
      "last_edit": lastEdit.toIso8601String(),
      "preview": preview,
      "category": category.name,
    };
  }
}
