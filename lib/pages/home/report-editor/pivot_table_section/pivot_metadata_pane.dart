import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';

class PivotMetadataPane extends StatelessWidget {
  const PivotMetadataPane({super.key, required this.files, required this.bloc});

  final List<String> files;
  final PivotTableBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Archivos de datos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    files.map((path) {
                      var filename =
                          File(path).path.split(Platform.pathSeparator).last;
                      return InputChip(
                        label: Text(filename),
                        deleteButtonTooltipMessage: "Eliminar",
                        onDeleted: () async {
                          await bloc.onFileRemoved(path);
                        },
                      );
                    }).toList(),
              ),
              TextButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        allowMultiple: false,
                        allowedExtensions: [".xls"],
                      );
                  if (result != null) {
                    var file = result.files[0].path!;
                    await bloc.onFileAdded(file);
                  }
                },
                label: Text("Añadir archivo"),
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
