import 'package:ut_report_generator/models/response/edit_pivot_table_response.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<EditPivotTableResponse> removeFile({
  required String report,
  required String pivotTable,
  required String fileName,
}) {
  return sendRequest(
    route: "pivot_table/remove_file",
    body: {"report": report, "pivot_table": pivotTable, "file": fileName},
    callback: EditPivotTableResponse.fromJson,
  );
}
