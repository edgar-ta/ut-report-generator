import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/testing_components/chips_tile.dart';
import 'package:ut_report_generator/testing_components/dropdown_menus_tile.dart';
import 'package:ut_report_generator/testing_components/slide_frame.dart';

class StudentData {
  final String professor;
  final int unit;
  final String subject;
  final int failedStudents;

  StudentData({
    required this.professor,
    required this.unit,
    required this.subject,
    required this.failedStudents,
  });
}

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final random = Random();

  late List<StudentData> data;

  String selectedProfessor = "Gregorio Rodríguez";
  String selectedSecondary = "Gregorio Rodríguez";
  List<ChipsTileEntry<String>> subjectEntries = [];
  List<ChipsTileEntry<int>> unitEntries = [];

  @override
  void initState() {
    super.initState();

    // Generar datos aleatorios
    const professors = ["Gregorio Rodríguez", "Brenda Juárez", "Luz María"];
    const subjects = ["POO", "DSM", "Bases de Datos", "Cálculo", "Inglés"];
    const units = [1, 2, 3, 4];

    data = List.generate(80, (_) {
      return StudentData(
        professor: professors[random.nextInt(professors.length)],
        unit: units[random.nextInt(units.length)],
        subject: subjects[random.nextInt(subjects.length)],
        failedStudents: random.nextInt(20),
      );
    });

    subjectEntries =
        subjects
            .map(
              (s) => ChipsTileEntry<String>(
                key: ValueKey(s),
                value: s,
                selected: true,
              ),
            )
            .toList();

    unitEntries =
        units
            .map(
              (u) => ChipsTileEntry<int>(
                key: ValueKey(u.toString()),
                value: u,
                selected: true,
              ),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    var controlData = [
      {
        "level": "professor",
        "options": ["Goyo", "Luzma", "Brenda"],
        "selected": ["Gregorio Rodriguez Miranda"],
      },
      {
        "level": "unit",
        "values": ["Unidad 1", "Unidad 2"],
      },
      {
        "level": "subjects",
        "values": ["Luzma", "Brenda"],
      },
    ];

    var graphData = {
      "Unidad 1": {"Luzma": 9.5, "René": 3.2, "Brenda": 5},
      "Unidad 2": {"Luzma": 9.5, "René": 3.2, "Brenda": 5},
      "Unidad 3": {"Luzma": 9.5, "René": 3.2, "Brenda": 5},
    };

    var identifiers = [0, -1, 1, 2];

    final professors = this.data.map((d) => d.professor).toSet().toList();

    return SlideFrame(
      menuWidth: 512,
      menuContent: Column(
        children: [
          DropdownMenusTile<String>(
            title: "Profesor",
            primaryItems: ["Profesor"],
            secondaryItems: professors,
            selectedPrimary: "Profesor",
            selectedSecondary: selectedProfessor,
            primaryItemBuilder: (context, val) => Text(val.toString()),
            secondaryItemBuilder: (context, val) => Text(val.toString()),
            onPrimaryChanged: (_) {},
            onSecondaryChanged:
                (val) => setState(() => selectedProfessor = val),
            onDelete: () {},
            index: 0,
          ),
          ChipsTile<String>(
            title: "Materias",
            entries: subjectEntries,
            chipBuilder:
                (context, val, selected) => Chip(
                  label: Text(val),
                  backgroundColor: selected ? Colors.blue : Colors.grey[300],
                ),
            onDelete: () {},
            index: 1,
          ),
          ChipsTile<int>(
            title: "Unidades",
            entries: unitEntries,
            chipBuilder:
                (context, val, selected) => Chip(
                  label: Text("Unidad $val"),
                  backgroundColor: selected ? Colors.green : Colors.grey[300],
                ),
            onDelete: () {},
            index: 2,
          ),
        ],
      ),
      child: Container(
        width: 1024,
        height: 512,
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: _buildBarGroups(),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) => Text("Unidad ${val.toInt()}"),
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final filtered =
        data.where((d) => d.professor == selectedProfessor).toList();

    final selectedSubjects =
        subjectEntries.where((e) => e.selected).map((e) => e.value).toList();
    final selectedUnits =
        unitEntries.where((e) => e.selected).map((e) => e.value).toList();

    return selectedUnits.map((unit) {
      final rods = <BarChartRodData>[];
      for (final subject in selectedSubjects) {
        final entries =
            filtered
                .where((d) => d.unit == unit && d.subject == subject)
                .toList();
        final double avg =
            entries.isNotEmpty
                ? entries.map((e) => e.failedStudents).reduce((a, b) => a + b) /
                    entries.length
                : 0;
        rods.add(BarChartRodData(toY: avg, width: 15));
      }
      return BarChartGroupData(x: unit, barRods: rods);
    }).toList();
  }
}
