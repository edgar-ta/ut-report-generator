import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/recent_reports_response.dart';

Future<RecentReportsResponse> recentReports({String? identifier}) {
  return sendRequest(
    route: "report/get_recent",
    body: {"report": identifier},
    callback: RecentReportsResponse.fromJson,
  );
}
