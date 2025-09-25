import 'package:ut_report_generator/models/response/file_response.dart';

class ExportBoxEntry {
  String identifier;
  Future<FileResponse> process;

  ExportBoxEntry({required this.identifier, required this.process});
}
