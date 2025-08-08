import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/start_report.dart';

class PickFileButton extends StatefulWidget {
  String message;
  final Future<void> Function(String)? onFilePicked;

  PickFileButton({Key? key, required this.message, this.onFilePicked})
    : super(key: key);

  @override
  _PickFileButtonState createState() => _PickFileButtonState();
}

class _PickFileButtonState extends State<PickFileButton> {
  bool isLoading = false;

  Future<void> _pickFileAndSendRequest() async {
    // Open file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx', 'csv'], // Restrict to JSON files
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      if (widget.onFilePicked != null) {
        setState(() {
          isLoading = true;
        });
        await widget.onFilePicked!(file.absolute.path).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No se pudo cambiar el archivo")),
          );
        });
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : _pickFileAndSendRequest,
      child:
          isLoading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(widget.message),
    );
  }
}
