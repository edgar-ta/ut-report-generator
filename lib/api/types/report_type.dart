import 'package:ut_report_generator/api/types/slide_type.dart';

class ReportType {
  String reportName;
  String reportDirectory;
  List<SlideType> slides;

  ReportType({
    required this.reportName,
    required this.reportDirectory,
    required this.slides,
  });

  factory ReportType.fromJson(Map<String, dynamic> json) {
    return ReportType(
      reportName: json['report_name'] as String,
      reportDirectory: json['report_directory'] as String,
      slides:
          (json['slides'] as List)
              .map((slide) => SlideType.fromJson(slide))
              .toList(),
    );
  }
}
