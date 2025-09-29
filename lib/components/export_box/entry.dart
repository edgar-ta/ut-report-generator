import 'package:ut_report_generator/components/export_box/widget.dart';
import 'package:ut_report_generator/models/response/file_response.dart';

class ExportBoxEntry {
  String identifier;
  ExportBoxEntryStatus status;
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
            () =>
                (this..response = response)
                  ..status = ExportBoxEntryStatus.success,
          );
        })
        .catchError((error) {
          setState(() => this..status = ExportBoxEntryStatus.error);
        });
  }
}

enum ExportBoxEntryStatus { pending, success, error }
