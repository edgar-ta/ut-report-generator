import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerButton extends StatefulWidget {
  Future<void> Function(String filePath)? onFileSelected;
  FilePickerButton({super.key, this.onFileSelected});

  @override
  State<FilePickerButton> createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  @override
  Widget build(BuildContext context) {
    double buttonHeight = 48;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: buttonHeight,
          child: TextButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                File file = File(result.files.single.path!);
                await widget.onFileSelected?.call(file.absolute.path);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(int.parse("0x10002855")),
              foregroundColor: Colors.black,
              textStyle: TextStyle(fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                  right: Radius.circular(0),
                ),
              ),
            ),
            child: Text("Seleccionar archivo"),
          ),
        ),
        SizedBox(
          height: buttonHeight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_downward, size: 12),
            style: IconButton.styleFrom(
              backgroundColor: Color(int.parse("0x10002855")),
              hoverColor: Color(int.parse("0x20002855")),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(0),
                  right: Radius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
