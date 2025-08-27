import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

class PivotTableChart extends StatefulWidget {
  final PivotData data;
  final String chartName;

  const PivotTableChart({
    super.key,
    required this.data,
    required this.chartName,
  });

  @override
  State<PivotTableChart> createState() => _PivotTableChartState();
}

class _PivotTableChartState extends State<PivotTableChart> {
  int? touchedGroupIndex;
  int? touchedRodIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16,
        children: [
          Text(widget.chartName, style: TextStyle(fontSize: 24)),
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
                        var title =
                            widget.data
                                .toJson()
                                .entries
                                .toList()[value.toInt()]
                                .key;
                        return SideTitleWidget(meta: meta, child: Text(title));
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      var groupData =
                          pivotTable.data.entries.toList()[groupIndex];
                      var rodTitle =
                          groupData.value.entries.toList()[rodIndex].key;
                      return BarTooltipItem(
                        "$rodTitle\n",
                        TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
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
                barGroups: createBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> createBarGroups() {
    switch (widget.data) {
      case FlatData(data: final flatData):
        return flatData;
      case GroupedData(data: final groupedData):
        return groupedData.entries.indexed.map((outerParameters) {
          final (groupIndex, groupEntry) = outerParameters;
          final groupData = groupEntry.value;

          return BarChartGroupData(
            x: groupIndex,
            barsSpace: 8,
            barRods:
                groupData.entries.indexed.map((parameters) {
                  var (rodIndex, rodEntry) = parameters;
                  var isTouched =
                      rodIndex == touchedRodIndex &&
                      groupIndex == touchedGroupIndex;

                  final value = (rodEntry.value as num).toDouble();
                  return BarChartRodData(
                    toY: value,
                    width: 256 / groupData.entries.length,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.zero,
                      top: Radius.circular(8),
                    ),
                    color: Colors.blue,
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
