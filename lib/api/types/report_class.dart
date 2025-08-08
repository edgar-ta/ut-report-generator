import 'package:ut_report_generator/api/types/slide_class.dart';

class ReportClass {
  String reportName;
  String reportDirectory;
  List<SlideClass> slides;

  ReportClass({
    required this.reportName,
    required this.reportDirectory,
    required this.slides,
  });

  factory ReportClass.fromJson(Map<String, dynamic> json) {
    return ReportClass(
      reportName: json['report_name'] as String,
      reportDirectory: json['report_directory'] as String,
      slides:
          (json['slides'] as List)
              .map((slide) => SlideClass.fromJson(slide))
              .toList(),
    );
  }

  ReportClass copyWith({
    String? reportName,
    String? reportDirectory,
    List<SlideClass>? slides,
  }) {
    return ReportClass(
      reportName: reportName ?? this.reportName,
      reportDirectory: reportDirectory ?? this.reportDirectory,
      slides: slides ?? this.slides,
    );
  }
}
