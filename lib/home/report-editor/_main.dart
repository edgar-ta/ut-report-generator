import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/home/report-editor/_test.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/widget.dart';

class ReportEditor extends StatefulWidget {
  StartReport_Response response;

  ReportEditor({super.key, required this.response});

  @override
  State<ReportEditor> createState() => _ReportEditorState();
}

class _ReportEditorState extends State<ReportEditor> {
  late TextEditingController reportNameController;

  @override
  void initState() {
    super.initState();
    reportNameController = TextEditingController(
      text: widget.response.reportName,
    );
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
                  FailureSection(response: widget.response),
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
