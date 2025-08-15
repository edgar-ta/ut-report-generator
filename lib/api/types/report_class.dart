import 'package:ut_report_generator/api/types/slide_class.dart';

class ReportClass {
  String rootDirectory;
  String reportName;
  DateTime creationDate;
  List<SlideClass> slides;
  String renderedFile;

  ReportClass({
    required this.rootDirectory,
    required this.reportName,
    required this.creationDate,
    required this.slides,
    required this.renderedFile,
  });

  factory ReportClass.fromJson(Map<String, dynamic> json) {
    return ReportClass(
      rootDirectory: json['report_directory'] as String,
      reportName: json['report_name'] as String,
      creationDate: DateTime.parse(json['creation_date']),
      slides:
          (json['slides'] as List)
              .map((slide) => SlideClass.fromJson(slide))
              .toList(),
      renderedFile: json['rendered_file'] as String,
    );
  }

  ReportClass copyWith({
    String? reportName,
    String? rootDirectory,
    DateTime? creationDate,
    List<SlideClass>? slides,
    String? renderedFile,
  }) {
    return ReportClass(
      reportName: reportName ?? this.reportName,
      rootDirectory: rootDirectory ?? this.rootDirectory,
      creationDate: creationDate ?? this.creationDate,
      slides: slides ?? this.slides,
      renderedFile: renderedFile ?? this.renderedFile,
    );
  }
}
