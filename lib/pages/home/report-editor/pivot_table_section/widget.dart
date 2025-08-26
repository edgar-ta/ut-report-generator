import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/edit_pivot_table.dart';
import 'package:ut_report_generator/models/pivot_table/custom_indexer.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/tabbed_menu.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/chips_tile.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/dropdown_menus_tile.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_without.dart';
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
  // ignore: non_constant_identifier_names
  static String SHOW_SECTION_KEY = "showValues";
  // ignore: non_constant_identifier_names
  static int MANDATORY_SHOW_FILTERS = 2;

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
  bool isLoading = false;

  late PivotTable pivotTable;
  late List<String> menuComponents;

  int touchedGroupIndex = -1;
  int touchedRodIndex = -1;
  late TextEditingController nameController;

  final FocusNode focusNode = FocusNode();
  bool hasFocus = false;

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

    menuComponents =
        pivotTable.arguments.map((argument) => argument.level.name).toList();
    menuComponents.insert(1, PivotTableSection.SHOW_SECTION_KEY);

    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    });
  }

  CustomIndexer getIndexer(
    List<CustomIndexer> indexers,
    PivotTableLevel level,
  ) {
    return indexers.firstWhere((element) => element.level == level);
  }

  Future<void> reorderFilter(int oldIndex, int newIndex) async {
    var indexOfSeparator = menuComponents.indexOf(
      PivotTableSection.SHOW_SECTION_KEY,
    );

    var elementsBeforeSeparator = indexOfSeparator;
    var elementsAfterSeparator = menuComponents.length - indexOfSeparator - 1;
    var goesForward =
        oldIndex < indexOfSeparator && newIndex >= indexOfSeparator;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    if ((goesForward && elementsBeforeSeparator <= 1) ||
        (goesForward && elementsAfterSeparator >= 2)) {
      if (newIndex == indexOfSeparator) {
        return;
      }
      setState(() {
        var element = menuComponents.removeAt(oldIndex);
        var separator = menuComponents.removeAt(indexOfSeparator - 1);
        menuComponents.insert(indexOfSeparator, separator);
        menuComponents.insert(newIndex, element);
      });
      await updatePivotTable();
      return;
    }

    setState(() {
      var element = menuComponents.removeAt(oldIndex);
      menuComponents.insert(newIndex, element);
    });

    await updatePivotTable();
  }

  Future<void> updatePivotTable() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      var orderedArguments =
          menuComponents
              .where((element) => element != PivotTableSection.SHOW_SECTION_KEY)
              .map((element) => PivotTableLevel.values.byName(element))
              .map((level) => getIndexer(pivotTable.arguments, level))
              .toList();

      final response = await editPivotTable(
        report: widget.report,
        pivotTable: pivotTable.identifier,
        arguments: orderedArguments,
      );

      setState(() {
        pivotTable = pivotTable.copyWith(
          parameters: response.parameters,
          arguments: response.arguments,
          data: response.data,
        );
      });
    } catch (e) {
      // Manejo simple de errores
      debugPrint("Error updating pivot table: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo actualizar el gráfico")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> changeVisualizationMode() async {
    var response = await api.changeVisualizationMode(
      report: widget.report,
      pivotTable: pivotTable.identifier,
      mode: pivotTable.mode,
    );

    setState(() {
      pivotTable = pivotTable.copyWith(preview: response.preview);
    });
  }

  @override
  Widget build(BuildContext context) {
    var positionOfSeparator = menuComponents.indexOf(
      PivotTableSection.SHOW_SECTION_KEY,
    );

    return SlideFrame(
      menuWidth: 512,
      menuContent: TabbedMenu(
        editTabBuilder: (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              spacing: 16,
              children: [
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nombre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: hasFocus ? Colors.black : Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextField(
                        focusNode: focusNode,
                        controller: nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeIn,
                      child: SegmentedButton(
                        key: ValueKey(pivotTable.mode),
                        segments: [
                          ButtonSegment(
                            value: SlideCategory.pivotTable,
                            label: Text("Gráfico"),
                            icon: Icon(Icons.bar_chart),
                          ),
                          ButtonSegment(
                            value: SlideCategory.imageSlide,
                            label: Text("Imagen"),
                            icon: Icon(Icons.image),
                          ),
                        ],
                        selected: {pivotTable.mode},
                        onSelectionChanged: (values) async {
                          setState(() {
                            pivotTable = pivotTable.copyWith(
                              mode: values.first,
                            );
                          });
                          await changeVisualizationMode();
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          "Filtrar por",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          onReorder: reorderFilter,
                          children: List.generate(menuComponents.length, (
                            index,
                          ) {
                            var id = menuComponents[index];
                            if (id == PivotTableSection.SHOW_SECTION_KEY) {
                              return ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                key: ValueKey(id),
                                title: Text(
                                  "Mostrar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            var level = PivotTableLevel.values.byName(id);
                            var parameters = getIndexer(
                              pivotTable.parameters,
                              level,
                            );
                            var arguments = getIndexer(
                              pivotTable.arguments,
                              level,
                            );

                            if (index < positionOfSeparator) {
                              return _buildDropdownMenusTile(
                                id,
                                parameters,
                                arguments,
                                level,
                                index,
                              );
                            }
                            return _buildChipsTile(
                              id,
                              parameters,
                              arguments,
                              level,
                              index,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  children: [
                    Text(
                      "Modo de visualización",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: pivotTable.mode == SlideCategory.pivotTable,
                      onChanged: (value) {
                        setState(() {
                          pivotTable = pivotTable.copyWith(
                            mode:
                                value
                                    ? SlideCategory.pivotTable
                                    : SlideCategory.imageSlide,
                          );
                        });
                      },
                    ),
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
      child:
          pivotTable.mode == SlideCategory.pivotTable
              ? (Padding(
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
                            checkToShowHorizontalLine:
                                (value) => value % 10 == 0,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryFixed,
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
                                  var title =
                                      pivotTable.data.entries
                                          .toList()[value.toInt()]
                                          .key;
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(title),
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
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                var groupData =
                                    pivotTable.data.entries
                                        .toList()[groupIndex];
                                var rodTitle =
                                    groupData.value.entries
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          barGroups:
                              pivotTable.data.entries.indexed.map((
                                outerParameters,
                              ) {
                                final (groupIndex, groupEntry) =
                                    outerParameters;
                                final groupData = groupEntry.value;

                                return BarChartGroupData(
                                  x: groupIndex,
                                  barsSpace: 8,
                                  barRods:
                                      groupData.entries.indexed.map((
                                        parameters,
                                      ) {
                                        var (rodIndex, rodEntry) = parameters;
                                        var isTouched =
                                            rodIndex == touchedRodIndex &&
                                            groupIndex == touchedGroupIndex;

                                        final value =
                                            (rodEntry.value as num).toDouble();
                                        return BarChartRodData(
                                          toY: value,
                                          width: 256 / groupData.entries.length,
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
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
              : Image.asset(pivotTable.preview ?? "assets/soy-ut-logo.png"),
    );
  }

  ChipsTile<String> _buildChipsTile(
    String id,
    CustomIndexer parameters,
    CustomIndexer arguments,
    PivotTableLevel level,
    int index,
  ) {
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
              if (arguments.values.length == 1) return;
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
  }

  DropdownMenusTile<String> _buildDropdownMenusTile(
    String id,
    CustomIndexer parameters,
    CustomIndexer arguments,
    PivotTableLevel level,
    int index,
  ) {
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
            arguments:
                pivotTable.arguments
                    .map(
                      (argument) =>
                          argument.level == level
                              ? argument.copyWith(values: [value])
                              : argument,
                    )
                    .toList(),
          );
        });
        await updatePivotTable();
      },
      index: index,
    );
  }
}
