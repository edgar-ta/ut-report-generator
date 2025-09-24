import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:ut_report_generator/api/file_response.dart';
import 'package:ut_report_generator/api/report/compile_report.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';
import 'package:open_dir/open_dir.dart';
import 'package:path/path.dart';

class ProgressAlertDialog<ResponseType extends FileResponse>
    extends StatefulWidget {
  final Future<ResponseType> Function() callback;
  final String title;

  const ProgressAlertDialog({
    super.key,
    required this.callback,
    required this.title,
  });

  @override
  State<ProgressAlertDialog> createState() => _ProgressAlertDialogState();
}

class _ProgressAlertDialogState<ResponseType extends FileResponse>
    extends State<ProgressAlertDialog<ResponseType>> {
  ResponseType? response;
  dynamic error;

  @override
  void initState() {
    super.initState();
    _renderReport();
  }

  Future<void> _renderReport() async {
    setState(() {
      response = null;
      error = null;
    });
    try {
      var serverResponse = await waitAtLeast(
        Duration(seconds: 2),
        widget.callback(),
      );
      setState(() {
        response = serverResponse;
        error = null;
      });
    } catch (thrownError) {
      setState(() {
        response = null;
        error = thrownError;
      });
    }
  }

  Widget _errorPreview() {
    return IntrinsicHeight(
      child: Column(
        children: [
          Text(error is Exception ? error.message : "Algo salió mal"),
          const SizedBox(height: 16),
          Icon(Icons.error, color: Colors.red, size: 50),
        ],
      ),
    );
  }

  Widget _loadingPreview() {
    return IntrinsicHeight(
      child: Column(children: [const CircularProgressIndicator()]),
    );
  }

  Widget _successPreview(dynamic response) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Text(response.message),
          const SizedBox(height: 16),
          Icon(Icons.check_circle, color: Colors.green, size: 64),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = response == null && error == null;
    var isError = error != null;
    var isSuccess = response != null;

    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),
      content:
          isLoading
              ? _loadingPreview()
              : isError
              ? _errorPreview()
              : _successPreview(response),
      actions: [
        if (!isLoading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        if (isSuccess)
          TextButton(
            onPressed: () async {
              // await OpenDir().openNativeDir(
              //   path: dirname(response!.outputFile),
              // );
              OpenFile.open(response!.outputFile);
            },
            child: const Text("Ver archivo"),
          ),
        if (isError)
          TextButton(onPressed: _renderReport, child: const Text("Reintentar")),
      ],
    );
  }
}
