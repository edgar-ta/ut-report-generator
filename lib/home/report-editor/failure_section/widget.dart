import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_clipboard/image_clipboard.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/edit_slide.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/failure_section_arguments.dart';
import 'package:ut_report_generator/home/report-editor/report_section/pick_file_button.dart';
import 'package:ut_report_generator/home/report-editor/report_section/widget.dart';

class FailureSection extends StatefulWidget {
  SlideClass slideData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData;
  ImageClipboard imageClipboard;

  FailureSection({
    super.key,
    required this.slideData,
    required this.editSlide,
    required this.changeSlideData,
    required this.imageClipboard,
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
      controlPanelBuilder: (arguments, updateArguments) {
        var parsedArguments = FailureSectionArguments.fromJson(arguments);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Unit Dropdown
              DropdownButton<int>(
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
