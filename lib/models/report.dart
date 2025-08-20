import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class ReportClass {
  String reportDirectory;
  String reportName;
  DateTime creationDate;
  List<Slide> slides;
  String renderedFile;

  ReportClass({
    required this.reportDirectory,
    required this.reportName,
    required this.creationDate,
    required this.slides,
    required this.renderedFile,
  });

  factory ReportClass.fromJson(Map<String, dynamic> json) {
    return ReportClass(
      reportDirectory: json['report_directory'] as String,
      reportName: json['report_name'] as String,
      creationDate: DateTime.parse(json['creation_date']),
      slides:
          (json['slides'] as List)
              .map(
                (slide) =>
                    SlideCategory.values.byName(slide['category']) ==
                            SlideCategory.image
                        ? PivotTable.fromJson(slide)
                        : PivotTable.fromJson(slide),
              )
              .toList(),
      renderedFile: json['rendered_file'] as String,
    );
  }

  ReportClass copyWith({
    String? reportName,
    String? reportDirectory,
    DateTime? creationDate,
    List<Slide>? slides,
    String? renderedFile,
  }) {
    return ReportClass(
      reportName: reportName ?? this.reportName,
      reportDirectory: reportDirectory ?? this.reportDirectory,
      creationDate: creationDate ?? this.creationDate,
      slides: slides ?? this.slides,
      renderedFile: renderedFile ?? this.renderedFile,
    );
  }
}
