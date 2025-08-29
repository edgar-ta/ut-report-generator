import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<EditPivotTable_Response> addFile({
  required String report,
  required String pivotTable,
  required String fileName,
}) {
  return sendRequest(
    route: "pivot_table/add_file",
    body: {"report": report, "pivot_table": pivotTable, "file": fileName},
    callback: EditPivotTable_Response.fromJson,
  );
}
