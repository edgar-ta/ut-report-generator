import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_table_chart.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/api/pivot_table/self.dart' as pivot_table;
import 'package:ut_report_generator/api/pivot_table/filter/self.dart' as filter;
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_with_replacement.dart';
import 'package:ut_report_generator/utils/copy_without.dart';

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
  void Function(PivotTable Function(PivotTable pivotTable) callback)
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
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.pivotTable.name)
      ..addListener(() {
        widget.updatePivotTable(
          (pivotTable) => pivotTable.copyWith(name: nameController.text),
        );
      });
  }

  Future<void> _onFileRemoved(String file) async {
    // @todo
    // route missing
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithout(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .removeFile(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          fileName: file,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _onFileAdded(String file) async {
    if (widget.pivotTable.source.files.contains(file)) {
      // Very naïve duplication checking that I'm not really sure I need
      return;
    }

    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithAdded(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .addFile(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          fileName: file,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _onOptionAdded(String option, int filterIndex) async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectedValues: copyWithAdded(filter.selectedValues, option),
          ),
        ),
      ),
    );

    await filter
        .addOptionToFilter(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          filter: filterIndex,
          option: option,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  // This function should handle invalid deletion cases. That is, when the
  // option is the last one in the filter, the user shouldn't be allowed to delete
  // it
  Future<void> _onOptionRemoved(String option, int filterIndex) async {
    if (widget.pivotTable.filters[filterIndex].selectedValues.length == 1) {
      return;
    }

    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectedValues: copyWithout(filter.selectedValues, option),
          ),
        ),
      ),
    );

    await filter
        .removeOptionFromFilter(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          filter: filterIndex,
          option: option,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _onOptionSwitched(String option, int filterIndex) async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(selectedValues: [option]),
        ),
      ),
    );

    await filter
        .switchOptionInFilter(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          filter: filterIndex,
          option: option,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _onFilterDeleted(int filterIndex) async {
    Future<void> Function() callback = () async {};

    if (widget.pivotTable.filters[filterIndex].chartingMode ==
        ChartingMode.chart) {
      if (widget.pivotTable.filters.length == 1) {
        return;
      }

      var newChartIndex = widget.pivotTable.filters.indexWhere(
        (filter) => filter.chartingMode == ChartingMode.none,
      );
      if (newChartIndex == -1) {
        newChartIndex = widget.pivotTable.filters.indexWhere(
          (filter) => filter.chartingMode != ChartingMode.chart,
        );
      }

      callback = () => _setChart(newChartIndex);
    }

    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithout(
          pivotTable.filters,
          pivotTable.filters[filterIndex],
        ),
      ),
    );

    await callback()
        .then(
          (_) => filter.deleteFilter(
            report: widget.report,
            pivotTable: widget.pivotTable.identifier,
            filter: filterIndex,
          ),
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _onFiltersReordered(int oldIndex, int newIndex) async {
    widget.updatePivotTable((pivotTable) {
      var filters = [...pivotTable.filters];
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      var filter = filters.removeAt(oldIndex);
      filters.insert(newIndex, filter);
      return pivotTable.copyWith(filters: filters);
    });

    await pivot_table.reorderFilter(
      report: widget.report,
      pivotTable: widget.pivotTable.identifier,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  Future<void> _toggleSelectionMode(int filterIndex) async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          widget.pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectionMode:
                filter.selectionMode == SelectionMode.many
                    ? SelectionMode.one
                    : SelectionMode.many,
            selectedValues:
                filter.selectionMode == SelectionMode.many
                    ? filter.selectedValues.isNotEmpty
                        ? [filter.selectedValues[0]]
                        : []
                    : filter.selectedValues,
          ),
        ),
      ),
    );

    // @todo Also, create an API for this
    await filter
        .toggleSelectionMode(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          filter: filterIndex,
        )
        .then((response) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(
              data: response.data,
              filters: response.filters,
            ),
          );
        });
  }

  Future<void> _swapChartingModes(
    int firstFilterIndex,
    int secondFilterIndex,
  ) async {
    var chartIndex = firstFilterIndex;
    var superChartIndex = secondFilterIndex;

    widget.updatePivotTable((pivotTable) {
      final firstFilterMode = pivotTable.filters[firstFilterIndex].chartingMode;
      final secondFilterMode =
          pivotTable.filters[secondFilterIndex].chartingMode;

      if (firstFilterMode == ChartingMode.superChart) {
        (chartIndex, superChartIndex) = (superChartIndex, chartIndex);
      }

      var filters = copyWithReplacement(
        pivotTable.filters,
        firstFilterIndex,
        (filter) => filter.copyWith(chartingMode: secondFilterMode),
      );
      filters = copyWithReplacement(
        filters,
        secondFilterIndex,
        (filter) => filter.copyWith(chartingMode: firstFilterMode),
      );

      return widget.pivotTable.copyWith(filters: filters);
    });

    pivot_table
        .setCharts(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          chart: chartIndex,
          superChart: superChartIndex,
        )
        .then((data) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(data: data),
          );
        });
  }

  // Makes the filter at `filterIndex` be of charting mode `chart`; the super chart,
  // if other than the filter edited, is left untouched and all other filters
  // acquire the charting mode `none`
  Future<void> _setChart(int filterIndex) async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              final (index, filter) = data;
              if (filterIndex == index) {
                return filter.copyWith(chartingMode: ChartingMode.chart);
              }
              if (filter.chartingMode == ChartingMode.superChart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          chart: filterIndex,
        )
        .then((data) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(data: data),
          );
        });
  }

  Future<void> _setSuperChart(int filterIndex) async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              var (index, filter) = data;
              if (index == filterIndex) {
                return filter.copyWith(chartingMode: ChartingMode.superChart);
              }
              if (filter.chartingMode == ChartingMode.chart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          superChart: filterIndex,
        )
        .then((data) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(data: data),
          );
        });
  }

  Future<void> _unsetSuperChart() async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              final (index, filter) = data;
              if (filter.chartingMode == ChartingMode.chart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: widget.report,
          pivotTable: widget.pivotTable.identifier,
          superChart: -1,
        )
        .then((data) {
          widget.updatePivotTable(
            (pivotTable) => pivotTable.copyWith(data: data),
          );
        });
  }

  Future<void> _toggleVisualizationMode() async {
    widget.updatePivotTable(
      (pivotTable) => pivotTable.copyWith(
        mode:
            pivotTable.mode == SlideCategory.pivotTable
                ? SlideCategory.imageSlide
                : SlideCategory.pivotTable,
      ),
    );

    await pivot_table.toggleVisualizationMode(
      report: widget.report,
      pivotTable: widget.pivotTable.identifier,
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
