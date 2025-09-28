import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/success_response.dart';

Future<SuccessResponse> toggleModeOfReport({required String report}) {
  return sendRequest(
    route: "/report/toggle_mode",
    body: {'report': report},
    callback: SuccessResponse.fromJson,
  );
}
