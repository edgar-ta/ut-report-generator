import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

Future<PivotData> setCharts({int? chart, int? superChart}) {
  return sendRequest(
    route: "pivot_table/set_charts",
    callback: PivotData.fromJson,
  );
}
