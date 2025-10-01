import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/recent_slideshows_response.dart';

Future<RecentSlideshowsResponse> getRecentSlideshows({String? identifier}) {
  return sendRequest(
    route: "report/get_recent",
    body: {"report": identifier},
    callback: RecentSlideshowsResponse.fromJson,
  );
}
