import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';

class ReportEditor extends StatefulWidget {
  StartReport_Response response;

  ReportEditor({super.key, required this.response});

  @override
  State<ReportEditor> createState() => _ReportEditorState();
}

class _ReportEditorState extends State<ReportEditor> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Nombre del reporte",
              hintText: "Ingrese el nombre del reporte",
            ),
          ),
        ],
      ),
    );
  }
}
