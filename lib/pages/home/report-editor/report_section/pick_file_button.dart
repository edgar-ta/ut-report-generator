import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/start_report.dart';

class PickFileButton extends StatefulWidget {
  String message;
  late List<String> allowedExtensions;
  final Future<void> Function(List<File>)? onFilesPicked;

  PickFileButton({
    Key? key,
    required this.message,
    this.onFilesPicked,
    List<String>? allowedExtensions,
  }) : super(key: key) {
    if (allowedExtensions == null) {
      this.allowedExtensions = ["xls", "xlsx", "csv"];
    } else {
      this.allowedExtensions = allowedExtensions;
    }
  }

  @override
  _PickFileButtonState createState() => _PickFileButtonState();
}

class _PickFileButtonState extends State<PickFileButton> {
  bool isLoading = false;

  Future<void> _pickFileAndSendRequest() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null) {
      if (widget.onFilesPicked != null) {
        setState(() {
          isLoading = true;
        });
        await widget.onFilesPicked!(
          result.files.map((platformFile) => File(platformFile.path!)).toList(),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _pickFileAndSendRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
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
      ),
    );
  }
}
