import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';

Future<DataFilter> createDataFilter({
  required String report,
  required String pivotTable,
  required PivotTableLevel level,
}) {
  return sendRequest(
    route: "pivot_table/filter/create",
    callback: DataFilter.fromJson,
    body: {"report": report, "pivot_table": pivotTable, "level": level.name},
  );
}
