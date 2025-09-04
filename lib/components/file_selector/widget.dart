import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/file_selector/file_entry.dart';

class FileSelector extends StatefulWidget {
  final List<String> initialFiles;
  final List<String> defaultSelection;
  final String? legend;

  const FileSelector({
    super.key,
    required this.initialFiles,
    required this.defaultSelection,
    required this.legend,
  });

  @override
  State<FileSelector> createState() => _FileSelectorState();
}

class _FileSelectorState extends State<FileSelector> {
  late List<String> files;
  late List<String> selectedFiles;

  @override
  void initState() {
    super.initState();
    files = widget.initialFiles;
    selectedFiles = widget.defaultSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Column(
            children: [
              Text("Seleccionar archivos"),
              Text(
                widget.legend ??
                    "Escoja los archivos de base para generar su tabla dinámica",
              ),
            ],
          ),
        ),
        Container(
          height: 512,
          child: ListView(
            children:
                files
                    .map(
                      (file) => FileEntry(
                        isSelected: selectedFiles.contains(file),
                        toggleSelected: () {},
                        path: file,
                      ),
                    )
                    .toList(),
          ),
        ),
        Container(
          child: Column(
            children: [
              TextButton.icon(
                onPressed: () {},
                label: Text("Seleccionar más"),
                icon: Icon(Icons.add),
              ),
              Row(
                children: [
                  TextButton.icon(onPressed: () {}, label: Text("Cancelar")),
                  TextButton.icon(onPressed: () {}, label: Text("Aceptar")),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
