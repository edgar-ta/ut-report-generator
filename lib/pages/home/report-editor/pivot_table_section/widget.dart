import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_table_chart.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/api/pivot_table/change_visualization_mode.dart'
    as api;

String levelToSpanish(PivotTableLevel level) {
  switch (level) {
    case PivotTableLevel.group:
      return "Grupo";
    case PivotTableLevel.professor:
      return "Profesor";
    case PivotTableLevel.subject:
      return "Materia";
    case PivotTableLevel.unit:
      return "Unidad";
    case PivotTableLevel.year:
      return "Año";
  }
}

class PivotTableSection extends StatefulWidget {
  String report;
  PivotTable pivotTable;
  void Function(PivotTable slide) updatePivotTable;

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
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.pivotTable.name)
      ..addListener(() {
        widget.updatePivotTable(
          widget.pivotTable.copyWith(name: nameController.text),
        );
      });
  }

  Future<void> _onFileRemoved(String file) async {}
  Future<void> _onFileAdded(String file) async {}

  Future<void> _onOptionAdded(String option, PivotTableLevel level) async {}
  Future<void> _onOptionRemoved(String option, PivotTableLevel level) async {}
  Future<void> _onOptionSwitched(String option, PivotTableLevel level) async {}

  Future<void> _onFilterDeleted(int filter) async {}
  Future<void> _onFiltersReordered(int oldIndex, int newIndex) async {}

  Future<void> _toggleSelectionMode(int filter) async {}

  Future<void> _swapChartingModes(int firstFilter, int secondFilter) async {}
  Future<void> _setChart(int filter) async {}
  Future<void> _setSuperChart(int filter) async {}
  Future<void> _unsetSuperChart(int filter) async {}

  Future<void> _onFilterEdited(PivotTableLevel level) async {
    try {
      final response = await editPivotTable(
        report: widget.report,
        pivotTable: widget.pivotTable.identifier,
        filters: widget.pivotTable.filters,
      );

      widget.updatePivotTable(
        widget.pivotTable.copyWith(
          filters: response.filters,
          data: response.data,
        ),
      );
    } catch (e) {
      // Manejo simple de errores
      debugPrint("Error updating pivot table: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo actualizar el gráfico")),
      );
    }
  }

  Future<void> _changeVisualizationMode() async {
    var response = await api.changeVisualizationMode(
      report: widget.report,
      pivotTable: widget.pivotTable.identifier,
      mode: widget.pivotTable.mode,
    );

    widget.updatePivotTable(
      widget.pivotTable.copyWith(preview: response.preview),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideFrame(
      menuWidth: 512,
      menuContent: TabbedMenu(
        editTabBuilder: (_) {
          return PivotEditPane(
            nameController: nameController,
            filters: widget.pivotTable.filters,
            onFileRemoved: _onFileRemoved,
            onFileAdded: _onFileAdded,
            onOptionAdded: _onOptionAdded,
            onOptionRemoved: _onOptionRemoved,
            onOptionSwitched: _onOptionSwitched,
            onFilterDeleted: _onFilterDeleted,
            onFiltersReordered: _onFiltersReordered,
            toggleSelectionMode: _toggleSelectionMode,
            swapChartingModes: _swapChartingModes,
            setChart: _setChart,
            setSuperChart: _setSuperChart,
            unsetSuperChart: _unsetSuperChart,
          );
        },
        metadataTabBuilder: (_) {
          return PivotMetadataPane(
            files: widget.pivotTable.source.files,
            onFileRemoved: _onFileRemoved,
            onFileAdded: _onFileAdded,
          );
        },
      ),
      child:
          widget.pivotTable.mode == SlideCategory.pivotTable
              ? (PivotTableChart(
                data: widget.pivotTable.data,
                chartName: widget.pivotTable.name,
              ))
              : Image.asset(
                widget.pivotTable.preview ?? "assets/soy-ut-logo.png",
              ),
    );
  }
}
