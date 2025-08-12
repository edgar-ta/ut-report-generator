import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:ut_report_generator/api/render_report.dart';
import 'package:ut_report_generator/home/report-editor/progress_alert_dialog/error_preview.dart';
import 'package:ut_report_generator/home/report-editor/progress_alert_dialog/success_preview.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

class ProgressAlertDialog extends StatefulWidget {
  final Future<RenderReport_Response> Function() renderReportCallback;
  final void Function(String outputFile) onReportGenerated;

  const ProgressAlertDialog({
    super.key,
    required this.renderReportCallback,
    required this.onReportGenerated,
  });

  @override
  State<ProgressAlertDialog> createState() => _ProgressAlertDialogState();
}

class _ProgressAlertDialogState extends State<ProgressAlertDialog> {
  bool isLoading = true;
  bool isError = false;
  RenderReport_Response? serverResponse;

  @override
  void initState() {
    super.initState();
    _renderReport();
  }

  Future<void> _renderReport() async {
    setState(() {
      isLoading = true;
      isError = false;
      serverResponse = null;
    });
    try {
      var response = await waitAtLeast(
        Duration(seconds: 2),
        widget.renderReportCallback(),
      );
      setState(() {
        isLoading = false;
        serverResponse = response;
      });
      widget.onReportGenerated(response.outputFile);
    } catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isSuccess = !isError && !isLoading;

    return AlertDialog(
      title: const Text("Generando PPTX"),
      content:
          isLoading
              ? const CircularProgressIndicator()
              : isError
              ? ErrorPreview()
              : SuccessPreview(message: serverResponse!.message),
      actions: [
        if (!isLoading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        if (isSuccess)
          TextButton(
            onPressed: () => OpenFile.open(serverResponse!.outputFile),
            child: const Text("Ver archivo"),
          ),
        if (isError)
          TextButton(onPressed: _renderReport, child: const Text("Reintentar")),
      ],
    );
  }
}
