import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/divide_length.dart';
import 'package:ut_report_generator/utils/round_up.dart';

class PivotTableSection extends StatefulWidget {
  final PivotData data;
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          spacing: 16,
          children: [
            Text(widget.chartName, style: const TextStyle(fontSize: 24)),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: getMaximumValueOfChart(),
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
                          switch (widget.data) {
                            case FlatData(data: final flatData):
                              title =
                                  flatData.entries.toList()[value.toInt()].key;
                            case GroupedData(data: final groupedData):
                              title =
                                  groupedData.entries
                                      .toList()[value.toInt()]
                                      .key;
                          }
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
                              Theme.of(context).colorScheme.primaryContainer,
                      getTooltipItem: createTooltipItem,
                    ),
                  ),
                  barGroups: createBarGroups(
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
    );
  }

  double getMaximumValueOfChart() {
    switch (widget.data) {
      case FlatData(data: final flatData):
        if (flatData.isEmpty) return 0;

        final maxValue = flatData.values.reduce((a, b) => a > b ? a : b);
        return roundUp(maxValue);

      case GroupedData(data: final groupedData):
        if (groupedData.isEmpty) return 0;

        // Tomamos los valores máximos de cada grupo
        final maxValue = groupedData.values
            .expand((group) => group.values)
            .reduce((a, b) => a > b ? a : b);

        return roundUp(maxValue);
    }
  }

  BarTooltipItem createTooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    String rodTitle;
    switch (widget.data) {
      case FlatData(data: final flatData):
        final entry = flatData.entries.toList()[groupIndex];
        rodTitle = entry.key;
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

      case GroupedData(data: final groupedData):
        final groupData = groupedData.entries.toList()[groupIndex];
        rodTitle = groupData.value.entries.toList()[rodIndex].key;
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
  }

  List<BarChartGroupData> createBarGroups({
    required double totalWidth,
    required double spaceBetweenBars,
    required double spaceBetweenBarGroups,
  }) {
    switch (widget.data) {
      case FlatData(data: final flatData):
        final numberOfBars = flatData.entries.length.toDouble();
        final barWidth = divideLength(
          length: totalWidth,
          itemCount: numberOfBars,
          spacing: spaceBetweenBars,
        );

        return flatData.entries.indexed.map((parameters) {
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
                color: widget.barColors[index % widget.barColors.length],
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 0, 247, 255),
                  width: isTouched ? 8 : 0,
                ),
              ),
            ],
          );
        }).toList();

      case GroupedData(data: final groupedData):
        final numberOfGroups = groupedData.entries.length.toDouble();
        final numberOfBars =
            groupedData.entries.toList()[0].value.entries.length.toDouble();

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

        return groupedData.entries.indexed.map((outerParameters) {
          final (groupIndex, groupEntry) = outerParameters;
          final groupData = groupEntry.value;

          return BarChartGroupData(
            x: groupIndex,
            barsSpace: spaceBetweenBars,
            barRods:
                groupData.entries.indexed.map((parameters) {
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
}
