import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';
import 'package:ut_report_generator/models/pivot_table/custom_indexer.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/assets_panel.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/tabbed_menu.dart';
import 'package:ut_report_generator/testing_components/chips_tile.dart';
import 'package:ut_report_generator/testing_components/dropdown_menus_tile.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_with_replacement.dart';
import 'package:ut_report_generator/utils/copy_without.dart';
import 'package:ut_report_generator/utils/reorder_element.dart';

String levelToSpanish(PivotTableLevel level) {
  switch (level) {
    case PivotTableLevel.gradeType:
      return "Número o letra";
    case PivotTableLevel.group:
      return "Grupo";
    case PivotTableLevel.professor:
      return "Profesor";
    case PivotTableLevel.subject:
      return "Materia";
    case PivotTableLevel.unit:
      return "Unidad";
  }
}

class PivotTableSection extends StatefulWidget {
  String report;
  PivotTable initialPivotTable;
  void Function(int index, Slide slide) updateSlide;

  PivotTableSection({
    super.key,
    required this.report,
    required this.initialPivotTable,
    required this.updateSlide,
  });

  @override
  State<PivotTableSection> createState() => _PivotTableSectionState();
}

class _PivotTableSectionState extends State<PivotTableSection> {
  late PivotTable pivotTable;
  bool isLoading = false;
  List<int> editTabComponents = [0, -1, 1, 2];

  int touchedGroupIndex = -1;
  int touchedRodIndex = -1;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    pivotTable = widget.initialPivotTable;
    nameController = TextEditingController(text: pivotTable.name)
      ..addListener(() {
        setState(() {
          pivotTable = pivotTable.copyWith(name: nameController.text);
        });
      });
  }

  Future<void> reorderFilter(int oldIndex, int newIndex) async {
    // var indexOfSeparator = editTabComponents;
  }

  Future<void> updatePivotTable() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await editPivotTable(
        report: widget.report,
        pivotTable: pivotTable.identifier,
        arguments: pivotTable.arguments,
      );

      setState(() {
        var indexOfSeparator = editTabComponents.indexOf(-1);
        for (var i = 0; i < indexOfSeparator; i++) {
          var identifier = editTabComponents[i];
          pivotTable.arguments[identifier].values[0] =
              pivotTable.parameters[identifier].values[0];
          // filter0, separator, filter1, filter2
          // filter1, separator, filter0, filter2
          // pivotTable.arguments[identifier]. = response.parameters[identifier];
        }

        pivotTable = pivotTable.copyWith(
          parameters: response.parameters,
          data: response.data,
        );
      });
    } catch (e) {
      // Manejo simple de errores
      debugPrint("Error updating pivot table: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update pivot table")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var positionOfSeparator = editTabComponents.indexOf(-1);

    return SlideFrame(
      menuWidth: 512,
      menuContent: TabbedMenu(
        editTabBuilder: (_) {
          return ReorderableListView(
            buildDefaultDragHandles: false,
            children: List.generate(editTabComponents.length, (index) {
              var id = editTabComponents[index];
              if (id == -1) {
                return ListTile(key: ValueKey(id), title: Text("Filtrar por"));
              }

              var parameters = pivotTable.parameters[id];
              var arguments = pivotTable.arguments[id];
              var level = parameters.level;

              if (index < positionOfSeparator) {
                return DropdownMenusTile<String>(
                  key: ValueKey(id),
                  title: levelToSpanish(parameters.level),
                  items: parameters.values,
                  selected: arguments.values[0],
                  itemBuilder: (context, value) {
                    return Text(value);
                  },
                  onChanged: (value) async {
                    setState(() {
                      pivotTable = pivotTable.copyWith(
                        arguments: copyWithReplacement(
                          pivotTable.arguments,
                          id,
                          (indexer) => indexer.copyWith(values: [value]),
                        ),
                      );
                    });
                    await updatePivotTable();
                  },
                  index: index,
                );
              }
              return ChipsTile<String>(
                key: ValueKey(id),
                title: levelToSpanish(parameters.level),
                entries:
                    parameters.values.map((parameter) {
                      return ChipsTileEntry(
                        key: ValueKey(parameter),
                        value: parameter,
                        selected: arguments.values.contains(parameter),
                      );
                    }).toList(),
                chipBuilder: (context, value, isSelected) {
                  return FilterChip(
                    label: Text(value),
                    onSelected: (innerIsSelected) async {
                      if (innerIsSelected) {
                        setState(() {
                          pivotTable = pivotTable.copyWith(
                            arguments:
                                pivotTable.arguments
                                    .map(
                                      (argument) =>
                                          argument.level != level
                                              ? argument
                                              : argument.copyWith(
                                                values: copyWithAdded(
                                                  argument.values,
                                                  value,
                                                ),
                                              ),
                                    )
                                    .toList(),
                          );
                        });
                        await updatePivotTable();
                      } else {
                        if (pivotTable.arguments[id].values.length == 1) return;
                        setState(() {
                          pivotTable = pivotTable.copyWith(
                            arguments:
                                pivotTable.arguments
                                    .map(
                                      (argument) =>
                                          argument.level != level
                                              ? argument
                                              : argument.copyWith(
                                                values: copyWithout(
                                                  argument.values,
                                                  value,
                                                ),
                                              ),
                                    )
                                    .toList(),
                          );
                        });
                        await updatePivotTable();
                      }
                    },
                    selected: isSelected,
                  );
                },
                index: index,
              );
            }),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                pivotTable = pivotTable.copyWith(
                  parameters: reorderElement(
                    pivotTable.parameters,
                    oldIndex,
                    newIndex,
                  ),
                  arguments: reorderElement(
                    pivotTable.arguments,
                    oldIndex,
                    newIndex,
                  ),
                );
              });
            },
          );
        },
        metadataTabBuilder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Nombre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextField(controller: nameController),
                  ],
                ),
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Archivos de datos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          pivotTable.source.files.map((path) {
                            var filename =
                                File(
                                  path,
                                ).path.split(Platform.pathSeparator).last;
                            return InputChip(
                              label: Text(filename),
                              onDeleted: () {},
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          spacing: 16,
          children: [
            Text(pivotTable.name, style: TextStyle(fontSize: 24)),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 75,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    checkToShowHorizontalLine: (value) => value % 10 == 0,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: Theme.of(context).colorScheme.primaryFixed,
                          strokeWidth: 1,
                        ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: 10,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          var entry =
                              (pivotTable.data[pivotTable
                                          .arguments[editTabComponents[0]]
                                          .values[0]]
                                      as Map<String, dynamic>)
                                  .entries
                                  .toList()[value.toInt()];
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(entry.key),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (touchEvent, barTouchResponse) {
                      if (!touchEvent.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          touchedRodIndex = -1;
                        });
                        return;
                      }
                      // barTouchResponse.spot!.touchedBarGroupIndex;
                      // barTouchResponse.spot!.touchedRodDataIndex;
                      setState(() {
                        touchedGroupIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                        touchedRodIndex =
                            barTouchResponse.spot!.touchedRodDataIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipMargin: 4,
                      getTooltipColor:
                          (group) =>
                              Theme.of(context).colorScheme.primaryContainer,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        var groupData =
                            (pivotTable.data[pivotTable
                                        .arguments[editTabComponents[0]]
                                        .values[0]]
                                    as Map<String, dynamic>)
                                .entries
                                .toList()[groupIndex];
                        var rodTitle =
                            (groupData.value as Map<String, dynamic>).entries
                                .toList()[rodIndex]
                                .key;
                        return BarTooltipItem(
                          "$rodTitle\n",
                          TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: rod.toY.toString(),
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups:
                      (pivotTable.data[pivotTable
                                  .arguments[editTabComponents[0]]
                                  .values[0]]
                              as Map<String, dynamic>)
                          .entries
                          .toList()
                          .asMap()
                          .entries
                          .map((outerEntry) {
                            final groupIndex = outerEntry.key;
                            // final teacherName = outerEntry.value.key;
                            final units =
                                outerEntry.value.value as Map<String, dynamic>;

                            return BarChartGroupData(
                              x: groupIndex,
                              barsSpace: 8,
                              barRods:
                                  units.entries.indexed.map((parameters) {
                                    var (rodIndex, unitEntry) = parameters;
                                    var isTouched =
                                        rodIndex == touchedRodIndex &&
                                        groupIndex == touchedGroupIndex;

                                    final value =
                                        (unitEntry.value as num).toDouble();
                                    return BarChartRodData(
                                      toY: value,
                                      width: 256 / units.entries.length,
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.zero,
                                        top: Radius.circular(8),
                                      ),
                                      color: Colors.blue,
                                      borderSide: BorderSide(
                                        color: const Color.fromARGB(
                                          255,
                                          0,
                                          247,
                                          255,
                                        ),
                                        width: isTouched ? 8 : 0,
                                      ),
                                    );
                                  }).toList(),
                            );
                          })
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
