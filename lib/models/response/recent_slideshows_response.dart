// ignore: camel_case_types
import 'package:ut_report_generator/models/response/report_preview.dart';

class RecentSlideshowsResponse {
  List<SlideshowPreview> reports;
  bool hasMore;
  String? lastReport;

  RecentSlideshowsResponse({
    required this.reports,
    required this.hasMore,
    required this.lastReport,
  });

  factory RecentSlideshowsResponse.fromJson(Map<String, dynamic> json) {
    return RecentSlideshowsResponse(
      reports:
          (json['reports'] as List<dynamic>)
              .map(
                (item) =>
                    SlideshowPreview.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      hasMore: json['has_more'] as bool,
      lastReport: json['last_report'] as String?,
    );
  }
}
