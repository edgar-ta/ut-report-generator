import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/file_selector/file_entry.dart';
import 'package:ut_report_generator/components/shaky-error-text/widget.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_without.dart';

class FileSelector extends StatefulWidget {
  final List<String> initialFiles;
  final List<String> defaultSelection;
  final String? legend;
  final Future<void> Function(List<String> files) onFilesSelected;

  const FileSelector({
    super.key,
    required this.initialFiles,
    required this.defaultSelection,
    required this.legend,
    required this.onFilesSelected,
  });

  @override
  State<FileSelector> createState() => _FileSelectorState();
}

class _FileSelectorState extends State<FileSelector> {
  late List<String> possibleFiles;
  late List<String> selectedFiles;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    possibleFiles = widget.initialFiles;
    selectedFiles = widget.defaultSelection;
  }

  void _addFileToSelection(String file) {
    if (!selectedFiles.contains(file)) {
      setState(() {
        selectedFiles = copyWithAdded(selectedFiles, file);
      });
    }
  }

  void _removeFileFromSelection(String file) {
    if (selectedFiles.contains(file)) {
      setState(() {
        selectedFiles = copyWithout(selectedFiles, file);
      });
    }
  }

  void _addPossibleFiles(List<String> files) {
    var newFiles = [...possibleFiles];
    for (var file in files) {
      if (!newFiles.contains(file)) {
        newFiles.add(file);
      }
    }

    setState(() {
      possibleFiles = newFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar archivos"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 1 / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShakyErrorText(
              isError: isError,
              removeError: () {
                setState(() {
                  isError = false;
                });
              },
              regularText:
                  widget.legend ??
                  "Escoja los archivos de base para generar su tabla dinámica",
              errorText: "Se debe seleccionar al menos un archivo",
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView(
                children:
                    possibleFiles.map((file) {
                      final isSelected = selectedFiles.contains(file);
                      return FileEntry(
                        isSelected: isSelected,
                        toggleSelected: () {
                          if (isSelected) {
                            _removeFileFromSelection(file);
                          } else {
                            _addFileToSelection(file);
                          }
                        },
                        path: file,
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                var result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  allowedExtensions: [
                    ".xls",
                  ], // ⚠️ puede que necesites fileType: FileType.custom
                );
                if (result != null) {
                  _addPossibleFiles(
                    result.files.map((file) => file.path!).toList(),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Seleccionar más"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () async {
            if (selectedFiles.isNotEmpty) {
              await widget.onFilesSelected(selectedFiles);
              Navigator.of(context).pop();
            } else {
              setState(() {
                isError = true;
              });
            }
          },
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
