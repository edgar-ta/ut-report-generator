import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_table_chart.dart';

class PivotTableSection extends StatefulWidget {
  final String report;
  final PivotTable pivotTable;
  final void Function(PivotTable Function(PivotTable pivotTable) callback)
  updatePivotTable;

  PivotTableSection({
    super.key,
    required this.report,
    required this.pivotTable,
    required this.updatePivotTable,
  });

  @override
  State<PivotTableSection> createState() => _PivotTableSectionState();
}

class _PivotTableSectionState extends State<PivotTableSection> {
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.pivotTable.title)
      ..addListener(() {
        widget.updatePivotTable(
          (pivotTable) => pivotTable.copyWith(title: titleController.text),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return PivotTableChart(
      data: widget.pivotTable.data,
      chartName: widget.pivotTable.title,
    );
  }
}
