import 'package:ut_report_generator/components/export_box/widget.dart';
import 'package:ut_report_generator/models/response/file_response.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class ExportBoxEntry {
  String identifier;
  FutureStatus status;
  Future<FileResponse> process;
  FileResponse? response;
  void Function(ExportBoxEntry Function()) setState;

  ExportBoxEntry({
    required this.identifier,
    required this.status,
    required this.process,
    required this.setState,
  }) {
    process
        .then((response) {
          setState(
            () => (this..response = response)..status = FutureStatus.success,
          );
        })
        .catchError((error) {
          setState(() => this..status = FutureStatus.error);
        });
  }
}
