import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/response/file_response.dart';

class ExportBox extends StatefulWidget {
  Future<FileResponse> future;
  void Function() remove;

  ExportBox({super.key, required this.future, required this.remove});

  @override
  State<ExportBox> createState() => _ExportBoxState();
}

class _ExportBoxState extends State<ExportBox> {
  void openDirectory(String path) {
    Process.run("explorer", [path], workingDirectory: path);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (!snapshot.hasError && !snapshot.hasData) {
          return Card(child: Text("Cargando"));
        }

        if (snapshot.hasError) {
          return Card(child: Text("Algo salió mal"));
        }

        final response = snapshot.data!;
        final directory = File(response.filepath).parent.absolute.path;
        return Card(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  widget.remove();
                },
                icon: Icon(Icons.close),
              ),
              GestureDetector(
                onTap: () {
                  openDirectory(directory);
                },
                child: Text(response.filepath),
              ),
            ],
          ),
        );
      },
    );
  }
}
