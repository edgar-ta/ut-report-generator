import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_data.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/divide_length.dart';
import 'package:ut_report_generator/utils/round_up.dart';

class PivotTableSection extends StatefulWidget {
  final PivotTableData data;
  final String chartName;
  final List<Color> barColors;

  const PivotTableSection({
    super.key,
    required this.data,
    required this.chartName,
    this.barColors = const [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.brown,
    ],
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
    final double spaceBetweenGarGroups = 10;

    return SizedBox(
      height: slideHeight(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          spacing: 16,
          children: [
            Text(widget.chartName, style: const TextStyle(fontSize: 24)),
            Expanded(
              child: Row(
                children: [
                  _legendList(widget.data),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        maxY: getMaximumValueOfChart(),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          checkToShowHorizontalLine: (value) => value % 10 == 0,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color:
                                    Theme.of(context).colorScheme.primaryFixed,
                                strokeWidth: 1,
                              ),
                        ),
                        titlesData: _titles(widget.data),
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
                            getTooltipItem: _tooltipItem,
                          ),
                        ),
                        barGroups: _barGroups(
                          spaceBetweenBarGroups: spaceBetweenGarGroups,
                          spaceBetweenBars: spaceBetweenBars,
                          totalWidth: totalWidth,
                        ),
                        groupsSpace: spaceBetweenGarGroups,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titles(PivotTableData data) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
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
            String title;
            switch (data) {
              case PivotTableRodClass(contents: final rods):
                title = rods[value.toInt()].key;
              case PivotTableRodGroupClass(contents: final rodGroups):
                title = rodGroups[value.toInt()].key;
            }
            return SideTitleWidget(meta: meta, child: Text(title));
          },
        ),
      ),
    );
  }

  double getMaximumValueOfChart() {
    switch (widget.data) {
      case PivotTableRodClass(contents: final rods):
        if (rods.isEmpty) return 0;

        final maxValue = rods.reduce((a, b) => a.value > b.value ? a : b).value;
        return roundUp(maxValue);

      case PivotTableRodGroupClass(contents: final rodGroups):
        if (rodGroups.isEmpty) return 0;

        final maxValue =
            rodGroups
                .expand((group) => group.rods)
                .reduce((a, b) => a.value > b.value ? a : b)
                .value;

        return roundUp(maxValue);
    }
  }

  BarTooltipItem _tooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    String rodTitle;
    switch (widget.data) {
      case PivotTableRodClass(contents: final rods):
        final entry = rods[groupIndex];
        rodTitle = entry.key;

      case PivotTableRodGroupClass(contents: final rodGroups):
        final groupData = rodGroups[groupIndex];
        rodTitle = groupData.rods[rodIndex].key;
    }

    return BarTooltipItem(
      "$rodTitle\n",
      TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text: rod.toY.toString(),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  List<BarChartGroupData> _barGroups({
    required double totalWidth,
    required double spaceBetweenBars,
    required double spaceBetweenBarGroups,
  }) {
    switch (widget.data) {
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
              BarChartRodData(
                toY: value,
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.zero,
                  top: Radius.circular(8),
                ),
                color: entry.color,
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 0, 247, 255),
                  width: isTouched ? 8 : 0,
                ),
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
                  return BarChartRodData(
                    toY: value,
                    width: barWidth,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.zero,
                      top: Radius.circular(8),
                    ),
                    color: widget.barColors[rodIndex % widget.barColors.length],
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 0, 247, 255),
                      width: isTouched ? 8 : 0,
                    ),
                  );
                }).toList(),
          );
        }).toList();
    }
  }

  Widget _legendList(PivotTableData data) {
    final Iterable<String> keys;

    if (data is PivotTableRodClass) {
      keys = data.contents.map((element) => element.key);
    } else if (data is PivotTableRodGroupClass) {
      keys = data.contents[0].rods.map((element) => element.key);
    } else {
      throw Exception("La variable data no es de ningún tipo de dato aceptado");
    }

    return SizedBox(
      width: 128,
      child: Column(
        spacing: 16,
        children:
            keys.indexed.map((key) {
              final (index, value) = key;
              return Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: widget.barColors[index % widget.barColors.length],
                  ),
                  Expanded(
                    child: Container(
                      child: Text(_titleCase(value), softWrap: true),
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
          // return bit.replaceFirstMapped(
          //   '^.',
          //   (match) => match.group(1)?.toUpperCase() ?? '',
          // );
        })
        .join(' ');
  }
}
