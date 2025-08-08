import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/edit_slide.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/report_class.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/widget.dart';

Widget buildSlideEditor(
  SlideClass slide,
  Future<void> Function(String slideId, String newFilePath) changeSlideData,
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide,
) {
  switch (slide.type) {
    case SlideType.failureRate:
      return FailureSection(
        key: ValueKey(slide.id),
        slideData: slide,
        editSlide: editSlide,
        changeSlideData: changeSlideData,
      );
    case SlideType.average:
      return Center(child: Text("Tipo de diapositiva no soportado"));
    default:
      return Center(child: Text("Tipo de diapositiva no soportado"));
  }
}

class ReportEditor extends StatefulWidget {
  ReportClass initialReport;

  ReportEditor({super.key, required this.initialReport});

  @override
  State<ReportEditor> createState() => _ReportEditorState();
}

class _ReportEditorState extends State<ReportEditor> {
  late TextEditingController reportNameController;
  late ReportClass report;

  @override
  void initState() {
    super.initState();
    report = widget.initialReport;
    reportNameController = TextEditingController(
      text: widget.initialReport.reportName,
    );
  }

  void setSlideData({
    required String slideId,
    List<AssetClass>? assets,
    String? preview,
    Map<String, dynamic>? arguments,
  }) {
    setState(() {
      var slides =
          report.slides.map((slide) {
            if (slide.id == slideId) {
              return slide.copyWith(
                assets: assets,
                preview: preview,
                arguments: arguments,
              );
            }
            return slide;
          }).toList();
      var newReport = report.copyWith(slides: slides);
      report = newReport;
    });
  }

  Future<void> _changeSlideData(String slideId, String newFilePath) async {
    return changeSlideData(
      newDataFile: newFilePath,
      reportDirectory: report.reportDirectory,
      slideId: slideId,
    ).then((value) {
      setSlideData(
        slideId: slideId,
        assets: value.assets,
        preview: value.preview,
      );
    });
  }

  Future<void> _editSlide(String slideId, Map<String, dynamic> arguments) {
    return editSlide(
      reportDirectory: report.reportDirectory,
      slideId: slideId,
      arguments: arguments,
    ).then((value) {
      setSlideData(
        slideId: slideId,
        assets: value.assets,
        preview: value.preview,
        arguments: arguments,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 128.0,
                vertical: 64,
              ),
              child: Column(
                spacing: 32,
                children: [
                  InputComponent(
                    label: "Nombre del reporte",
                    hint: "Ingrese el nombre del reporte",
                    controller: reportNameController,
                  ),
                  ...(report.slides.map((slide) {
                    return buildSlideEditor(
                      slide,
                      _changeSlideData,
                      _editSlide,
                    );
                  }).toList()),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton.icon(
              onPressed: () {},
              label: Text("Generar reporte"),
              icon: Icon(Icons.check),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
