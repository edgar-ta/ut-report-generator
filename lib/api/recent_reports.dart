import 'package:ut_report_generator/api/send_request.dart';

Future<RecentReports_Response> recentReports({String? referenceReport}) {
  return sendRequest(
    route: "recent_reports",
    body: {"reference_report": referenceReport},
    callback: RecentReports_Response.fromJson,
  );
}

// ignore: camel_case_types
class RecentReports_ReportPreview {
  String preview;
  String name;
  String rootDirectory;

  RecentReports_ReportPreview({
    required this.preview,
    required this.name,
    required this.rootDirectory,
  });

  factory RecentReports_ReportPreview.fromJson(Map<String, dynamic> json) {
    return RecentReports_ReportPreview(
      preview: json['preview'] as String,
      name: json['name'] as String,
      rootDirectory: json['root_directory'] as String,
    );
  }
}

// ignore: camel_case_types
class RecentReports_Response {
  List<RecentReports_ReportPreview> reports;
  bool hasMore;
  String lastReport;

  RecentReports_Response({
    required this.reports,
    required this.hasMore,
    required this.lastReport,
  });

  factory RecentReports_Response.fromJson(Map<String, dynamic> json) {
    return RecentReports_Response(
      reports:
          (json['reports'] as List<dynamic>)
              .map(
                (item) => RecentReports_ReportPreview.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      hasMore: json['has_more'] as bool,
      lastReport: json['last_report'] as String,
    );
  }
}
