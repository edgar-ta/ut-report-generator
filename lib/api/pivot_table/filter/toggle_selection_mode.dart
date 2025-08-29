import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/pivot_table/edit_pivot_table_response.dart';

Future<EditPivotTable_Response> toggleSelectionMode({
  required String report,
  required String pivotTable,
  required int filter,
}) {
  return sendRequest(
    route: "pivot_table/filter/toggle_selection_mode",
    body: {"report": report, "pivot_table": pivotTable, "filter": filter},
    callback: EditPivotTable_Response.fromJson,
  );
}
