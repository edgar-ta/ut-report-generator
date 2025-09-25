import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/models/response/file_response.dart';

class ExportBox extends StatefulWidget {
  ExportBoxEntry entry;
  void Function() remove;
  void Function() retry;

  ExportBox({
    super.key,
    required this.entry,
    required this.remove,
    required this.retry,
  });

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
      future: widget.entry.process,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child:
              !snapshot.hasError && !snapshot.hasData
                  ? _loadingState()
                  : (snapshot.hasError
                      ? _errorState()
                      : _normalState(snapshot)),
        );
      },
    );
  }

  Widget _loadingState() {
    return SizedBox(
      key: ValueKey("loading"),
      width: 256,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 48,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(child: Text("Cargando")),
            IconButton(onPressed: widget.remove, icon: Icon(Icons.close)),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return SizedBox(
      key: ValueKey("error"),
      width: 256,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 48,
              child: Icon(Icons.error, color: Colors.blueGrey[300]),
            ),
            Expanded(child: Text("Algo salió mal")),
            IconButton(onPressed: widget.retry, icon: Icon(Icons.replay)),
            IconButton(onPressed: widget.remove, icon: Icon(Icons.close)),
          ],
        ),
      ),
    );
  }

  Widget _normalState(AsyncSnapshot<FileResponse> snapshot) {
    final response = snapshot.data!;
    final directory = File(response.filepath).parent.absolute.path;
    final filename = path.split(response.filepath).last;
    return SizedBox(
      key: ValueKey("normal"),
      width: 256,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  openDirectory(directory);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    spacing: 6,
                    children: [
                      if (response.preview != null)
                        SizedBox.square(
                          dimension: 48,
                          child: Image.file(
                            File(response.preview!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          filename,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.remove();
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
