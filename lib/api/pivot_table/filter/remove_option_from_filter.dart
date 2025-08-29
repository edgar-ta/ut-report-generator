import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';

Future<EditPivotTable_Response> removeOptionFromFilter({
  required String report,
  required String pivotTable,
  required int filter,
  required String option,
}) {
  return sendRequest(
    route: "pivot_table/filter/remove",
    body: {
      "report": report,
      "pivot_table": pivotTable,
      "filter": filter,
      "option": option,
    },
    callback: EditPivotTable_Response.fromJson,
  );
}
