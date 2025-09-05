import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';

Future<PivotTable> createPivotTable({
  required String report,
  required List<String> dataFiles,
}) {
  return sendRequest(
    route: "pivot_table/create",
    body: {"report": report, "data_files": dataFiles},
    callback: PivotTable.fromJson,
  );
}
