import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/aggregate_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/filter_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_data.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/divide_length.dart';
import 'package:ut_report_generator/utils/round_up.dart';

class PivotTableSection extends StatefulWidget {
  final PivotTable pivotTable;
  final VisualizationMode mode;

  const PivotTableSection({
    super.key,
    required this.pivotTable,
    required this.mode,
  });

  @override
  State<PivotTableSection> createState() => _PivotTableSectionState();
}

class _PivotTableSectionState extends State<PivotTableSection> {
  int? touchedGroupIndex;
  int? touchedRodIndex;

  @override
  Widget build(BuildContext context) {
    final double totalWidth = MediaQuery.of(context).size.width * 3 / 4;
    final double spaceBetweenBars = 10;
    final double spaceBetweenGarGroups = 100;
    final double provisionalHeight = _provisionalHeight();

    return SizedBox(
      height: slideHeight(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child:
            widget.mode == VisualizationMode.chartsOnly
                ? _chart(
                  context,
                  spaceBetweenGarGroups,
                  spaceBetweenBars,
                  totalWidth,
                  provisionalHeight,
                )
                : Image.file(File(widget.pivotTable.preview)),
      ),
    );
  }

  Column _chart(
    BuildContext context,
    double spaceBetweenGarGroups,
    double spaceBetweenBars,
    double totalWidth,
    double provisionalHeight,
  ) {
    return Column(
      spacing: 16,
      children: [
        Text(
          widget.pivotTable.automaticTitle
              ? _automaticTitle(
                widget.pivotTable.aggregateFunction,
                widget.pivotTable.filterFunction,
                chartingLevel,
              )
              : widget.pivotTable.title,
          style: const TextStyle(fontSize: 24),
        ),
        Expanded(
          child: Row(
            children: [
              _legendList(widget.pivotTable.data),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: _maximumValueInChart(),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      checkToShowHorizontalLine: (value) => value % 10 == 0,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Theme.of(context).colorScheme.primaryFixed,
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: _titles(widget.pivotTable.data),
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
                        fitInsideVertically: true,
                        tooltipMargin: 12,
                        getTooltipColor:
                            (group) =>
                                Theme.of(context).colorScheme.tertiaryContainer,
                        getTooltipItem: _tooltipItem,
                        maxContentWidth: 200,
                        tooltipBorderRadius: BorderRadius.zero,
                      ),
                    ),
                    barGroups: _groupData(
                      spaceBetweenBarGroups: spaceBetweenGarGroups,
                      spaceBetweenBars: spaceBetweenBars,
                      totalWidth: totalWidth,
                      provisionalHeight: provisionalHeight,
                    ),
                    groupsSpace: spaceBetweenGarGroups,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  FlTitlesData _titles(PivotTableData data) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 48),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            String title;
            bool isMissing = false;
            int numberOfRods;

            switch (data) {
              case PivotTableRodClass(contents: final rods):
                title = rods[value.toInt()].key;
                isMissing = rods[value.toInt()].missing;
                numberOfRods = rods.length;
              case PivotTableRodGroupClass(contents: final rodGroups):
                title = rodGroups[value.toInt()].key;
                numberOfRods = rodGroups.length * rodGroups[0].rods.length;
            }
            // 25 caracteres funciona bien para cinco barras; luego,
            // para cada barra extra se cortan 10 caracteres
            int numberOfCharacters = max(10, 25 - (numberOfRods - 5) * 10);

            if (isMissing) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  _truncateText(
                    "*${_titleCase(title)}",
                    maxChars: numberOfCharacters,
                  ),
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(
                _truncateText(_titleCase(title), maxChars: numberOfCharacters),
                softWrap: true,
              ),
            );
          },
        ),
      ),
    );
  }

  double _maximumValueInChart() {
    switch (widget.pivotTable.data) {
      case PivotTableRodClass(contents: final rods):
        if (rods.isEmpty) return 0;

        final maxValue = rods.reduce((a, b) => a.value > b.value ? a : b).value;
        return max(roundUp(maxValue), 10);

      case PivotTableRodGroupClass(contents: final rodGroups):
        if (rodGroups.isEmpty) return 0;

        final maxValue =
            rodGroups
                .expand((group) => group.rods)
                .reduce((a, b) => a.value > b.value ? a : b)
                .value;

        return max(roundUp(maxValue), 10);
    }
  }

  double _minimumValueInChart() {
    switch (widget.pivotTable.data) {
      case PivotTableRodClass(contents: final rods):
        if (rods.isEmpty) return 0;

        final minValue = rods.reduce((a, b) => a.value < b.value ? a : b).value;
        return minValue;

      case PivotTableRodGroupClass(contents: final rodGroups):
        if (rodGroups.isEmpty) return 0;

        final minValue =
            rodGroups
                .expand((group) => group.rods)
                .reduce((a, b) => a.value < b.value ? a : b)
                .value;

        return minValue;
    }
  }

  BarTooltipItem _tooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    PivotTableRod currentRod;

    switch (widget.pivotTable.data) {
      case PivotTableRodClass(contents: final rods):
        currentRod = rods[groupIndex];

      case PivotTableRodGroupClass(contents: final rodGroups):
        final groupData = rodGroups[groupIndex];
        currentRod = groupData.rods[rodIndex];
    }

    if (currentRod.missing) {
      return BarTooltipItem(
        chartingLevel == PivotTableLevel.professor
            ? "${_titleCase(currentRod.key)} no ha subido calificaciones"
            : "No hay calificaciones registradas para ${_titleCase(currentRod.key)}",
        TextStyle(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          fontSize: 12,
        ),
      );
    }

    return BarTooltipItem(
      "${currentRod.value.toStringAsFixed(2)}\n",
      children: [
        TextSpan(
          text:
              "${_aggregateFunctionToSpanish(widget.pivotTable.aggregateFunction)} de ${_filterFunctionToSpanish(widget.pivotTable.filterFunction)} para ${currentRod.key}",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ],
      TextStyle(
        color: Theme.of(context).colorScheme.onTertiaryContainer,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  List<BarChartGroupData> _groupData({
    required double totalWidth,
    required double spaceBetweenBars,
    required double spaceBetweenBarGroups,
    required double provisionalHeight,
  }) {
    switch (widget.pivotTable.data) {
      case PivotTableRodClass(contents: final rods):
        final numberOfBars = rods.length.toDouble();
        final barWidth = divideLength(
          length: totalWidth,
          itemCount: numberOfBars,
          spacing: spaceBetweenBars,
        );

        return rods.indexed.map((parameters) {
          final (index, entry) = parameters;
          final value = (entry.value as num).toDouble();
          final isTouched = index == touchedGroupIndex;

          return BarChartGroupData(
            x: index,
            barsSpace: spaceBetweenBars,
            barRods: [
              _rodData(
                value: value,
                provisionalHeight: provisionalHeight,
                barWidth: barWidth,
                originalColor: entry.color,
                isTouched: isTouched,
                isMissing: entry.missing,
              ),
            ],
          );
        }).toList();

      case PivotTableRodGroupClass(contents: final rodGroups):
        final numberOfGroups = rodGroups.length.toDouble();
        final numberOfBars = rodGroups[0].rods.length.toDouble();

        final groupWidth = divideLength(
          length: totalWidth,
          itemCount: numberOfGroups,
          spacing: spaceBetweenBarGroups,
        );
        final barWidth = divideLength(
          length: groupWidth,
          itemCount: numberOfBars,
          spacing: spaceBetweenBars,
        );

        return rodGroups.indexed.map((outerParameters) {
          final (groupIndex, groupData) = outerParameters;

          return BarChartGroupData(
            x: groupIndex,
            barsSpace: spaceBetweenBars,
            barRods:
                groupData.rods.indexed.map((parameters) {
                  var (rodIndex, rodEntry) = parameters;
                  var isTouched =
                      rodIndex == touchedRodIndex &&
                      groupIndex == touchedGroupIndex;

                  final value = (rodEntry.value as num).toDouble();
                  return _rodData(
                    value: value,
                    provisionalHeight: provisionalHeight,
                    barWidth: barWidth,
                    originalColor: rodEntry.color,
                    isTouched: isTouched,
                    isMissing: rodEntry.missing,
                  );
                }).toList(),
          );
        }).toList();
    }
  }

  BarChartRodData _rodData({
    required double value,
    required double provisionalHeight,
    required double barWidth,
    required Color originalColor,
    required bool isTouched,
    required bool isMissing,
  }) {
    return BarChartRodData(
      toY: value == 0 ? provisionalHeight : value,
      width: barWidth,
      borderRadius: BorderRadius.zero,
      color:
          isMissing
              ? Colors.grey.withAlpha(128)
              : (isTouched ? originalColor : originalColor.withAlpha(128)),
    );
  }

  Widget _legendList(PivotTableData data) {
    final Iterable<({String key, Color color})> keysAndColors;

    if (data is PivotTableRodClass) {
      keysAndColors = data.contents.map(
        (element) => (key: element.key, color: element.color),
      );
    } else if (data is PivotTableRodGroupClass) {
      keysAndColors = data.contents[0].rods.map(
        (element) => (key: element.key, color: element.color),
      );
    } else {
      throw Exception("La variable data no es de ningún tipo de dato aceptado");
    }

    return SizedBox(
      width: 128,
      child: Column(
        spacing: 16,
        children:
            keysAndColors.indexed.map((entry) {
              final (index, value) = entry;
              final key = value.key;
              final color = value.color;
              return Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 16, height: 16, color: color),
                  Expanded(
                    child: Container(
                      child: Text(_titleCase(key), softWrap: true),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  String _titleCase(String string) {
    return string
        .split(' ')
        .map((bit) {
          return bit[0] + bit.substring(1).toLowerCase();
        })
        .join(' ');
  }

  double _provisionalHeight() {
    double maxHeight = _maximumValueInChart();
    double minHeight = _minimumValueInChart();
    if (minHeight > 0) {
      return max(minHeight / 2, 4);
    } else {
      return max(maxHeight / 10, 1);
    }
  }

  String _aggregateFunctionToSpanish(AggregateFunctionType aggregateFunction) {
    switch (aggregateFunction) {
      case AggregateFunctionType.average:
        return "Promedio";
      case AggregateFunctionType.count:
        return "Conteo";
      case AggregateFunctionType.max:
        return "Calificación más alta";
      case AggregateFunctionType.min:
        return "Calificación más baja";
    }
  }

  String _filterFunctionToSpanish(FilterFunctionType filterFunction) {
    switch (filterFunction) {
      case FilterFunctionType.allStudents:
        return "todos los estudiantes";
      case FilterFunctionType.approvedStudents:
        return "los estudiantes aprobados";
      case FilterFunctionType.failedStudents:
        return "los estudiantes no aprobados";
    }
  }

  String _truncateText(String text, {int maxChars = 12}) {
    if (text.length <= maxChars) return text;

    final words = text.split(RegExp(r'\s+'));
    var truncated = StringBuffer();
    var currentLength = 0;

    for (var word in words) {
      // +1 accounts for the space between words (except the first)
      final addedLength = (currentLength == 0 ? 0 : 1) + word.length;

      // If adding this word would exceed the limit, decide whether to keep it or not
      if (currentLength + addedLength > maxChars) {
        final diffIfExcluded = maxChars - currentLength;
        final diffIfIncluded = (currentLength + addedLength) - maxChars;

        // Keep the word if it makes the total length *closer* to the limit
        if (diffIfIncluded <= diffIfExcluded) {
          if (truncated.isNotEmpty) truncated.write(' ');
          truncated.write(word);
        }

        break;
      }

      if (truncated.isNotEmpty) truncated.write(' ');
      truncated.write(word);
      currentLength += addedLength;
    }

    return truncated.toString().trim();
  }

  PivotTableLevel get chartingLevel {
    for (final filter in widget.pivotTable.filters) {
      if (filter.chartingMode == ChartingMode.chart) {
        return filter.level;
      }
    }
    throw Exception("La tabla dinámica no tiene un filtro de gráfico");
  }

  String _automaticTitle(
    AggregateFunctionType aggregateFunction,
    FilterFunctionType filterFunction,
    PivotTableLevel level,
  ) {
    return "${_aggregateFunctionToSpanish(aggregateFunction)} de ${_filterFunctionToSpanish(filterFunction)} por ${levelToSpanish(level)}";
  }
}
