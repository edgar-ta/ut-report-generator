import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/pivot_table/visualization_mode.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class ReportClass {
  String identifier;
  String reportName;
  DateTime creationDate;
  List<Slide> slides;
  VisualizationMode visualizationMode;

  ReportClass({
    required this.identifier,
    required this.reportName,
    required this.creationDate,
    required this.slides,
    required this.visualizationMode,
  });

  factory ReportClass.fromJson(Map<String, dynamic> json) {
    return ReportClass(
      identifier: json['identifier'] as String,
      reportName: json['report_name'] as String,
      creationDate: DateTime.parse(json['creation_date']),
      slides:
          (json['slides'] as List)
              .map(
                (slide) =>
                    SlideCategory.values.byName(slide['category']) ==
                            SlideCategory.imageSlide
                        ? ImageSlide.fromJson(slide)
                        : PivotTable.fromJson(slide),
              )
              .toList(),
      visualizationMode: VisualizationMode.values.byName(
        json['visualization_mode'],
      ),
    );
  }

  ReportClass copyWith({
    String? identifier,
    String? reportName,
    DateTime? creationDate,
    List<Slide>? slides,
    VisualizationMode? visualizationMode,
  }) {
    return ReportClass(
      identifier: identifier ?? this.identifier,
      reportName: reportName ?? this.reportName,
      creationDate: creationDate ?? this.creationDate,
      slides: slides ?? this.slides,
      visualizationMode: visualizationMode ?? this.visualizationMode,
    );
  }
}
