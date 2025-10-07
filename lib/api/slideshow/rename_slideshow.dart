import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/success_response.dart';

Future<SuccessResponse> renameReport({
  required String report,
  required String name,
}) {
  return sendRequest(
    route: "/report/rename",
    body: {'report': report, 'name': name},
    callback: SuccessResponse.fromJson,
  );
}
