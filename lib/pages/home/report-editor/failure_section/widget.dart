import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/pages/home/report-editor/failure_section/failure_section_arguments.dart';
import 'package:ut_report_generator/pages/home/report-editor/report_section/pick_file_button.dart';
import 'package:ut_report_generator/pages/home/report-editor/report_section/widget.dart';

class FailureSection extends StatefulWidget {
  SlideClass slideData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData;

  FailureSection({
    super.key,
    required this.slideData,
    required this.editSlide,
    required this.changeSlideData,
  });

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
  @override
  Widget build(BuildContext context) {
    return ReportSection(
      slideData: widget.slideData,
      editSlide: widget.editSlide,
      changeSlideData: widget.changeSlideData,
      metadataPane: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              "Nombre",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(widget.slideData.id),
            Text(
              "Archivos",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Wrap(
              children:
                  widget.slideData.dataFiles.map((filePath) {
                    var filename =
                        File(filePath).path.split(Platform.pathSeparator).last;
                    return InputChip(
                      label: Text(filename),
                      deleteIcon: Icon(Icons.delete),
                      onDeleted: () {},
                    );
                  }).toList(),
            ),
            PickFileButton(
              message: "Cambiar archivos",
              onFilesPicked: (files) async {
                return widget.changeSlideData(widget.slideData.id, files);
              },
            ),
          ],
        ),
      ),
      editionPaneBuilder: (arguments, updateArguments) {
        var parsedArguments = FailureSectionArguments.fromJson(arguments);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Unit Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(label: Text("Unidad")),
                value: parsedArguments.unit,
                items: List.generate(5, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text("Unidad ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    updateArguments(
                      parsedArguments.copyWith(unit: value).toJson(),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
