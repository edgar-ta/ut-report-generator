// ignore: camel_case_types
import 'package:ut_report_generator/models/response/report_preview.dart';

class RecentReportsResponse {
  List<ReportPreview> reports;
  bool hasMore;
  String? lastReport;

  RecentReportsResponse({
    required this.reports,
    required this.hasMore,
    required this.lastReport,
  });

  factory RecentReportsResponse.fromJson(Map<String, dynamic> json) {
    return RecentReportsResponse(
      reports:
          (json['reports'] as List<dynamic>)
              .map(
                (item) => ReportPreview.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      hasMore: json['has_more'] as bool,
      lastReport: json['last_report'] as String?,
    );
  }
}
