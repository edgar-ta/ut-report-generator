import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/filter_component.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_with_replacement.dart';
import 'package:ut_report_generator/utils/copy_without.dart';

class TestingComponent extends StatefulWidget {
  const TestingComponent({super.key});

  @override
  State<TestingComponent> createState() => _TestingComponentState();
}

class _TestingComponentState extends State<TestingComponent> {
  List<DataFilter> filters = [
    DataFilter(
      level: PivotTableLevel.group,
      selectedValues: ["Primero", "Segundo"],
      possibleValues: ["Primero", "Segundo", "Tercero"],
      selectionMode: SelectionMode.one,
      chartingMode: ChartingMode.none,
    ),
    DataFilter(
      level: PivotTableLevel.professor,
      selectedValues: ["Profesor A"],
      possibleValues: ["Profesor A", "Profesor B", "Profesor C"],
      selectionMode: SelectionMode.one,
      chartingMode: ChartingMode.chart,
    ),
    DataFilter(
      level: PivotTableLevel.subject,
      selectedValues: ["Matemáticas", "Historia"],
      possibleValues: ["Matemáticas", "Historia", "Biología"],
      selectionMode: SelectionMode.many,
      chartingMode: ChartingMode.superChart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
