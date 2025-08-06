import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/input_component.dart';

class FailureSectionArguments {
  int unit;
  bool showDelayedTeachers;

  FailureSectionArguments({
    required this.unit,
    required this.showDelayedTeachers,
  });

  static FailureSectionArguments fromJson(dynamic map) {
    return FailureSectionArguments(
      unit: map['unit'] as int,
      showDelayedTeachers: map['show_delayed_teachers'] as bool,
    );
  }
}

class FailureSection extends StatefulWidget {
  StartReport_Response response;
  FailureSection({super.key, required this.response});

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
  // can be abstracted out
  late FailureSectionArguments arguments;

  // can be abstracted out
  FailureSectionArguments parseArguments(dynamic arguments) {
    return FailureSectionArguments.fromJson(arguments);
  }

  @override
  void initState() {
    super.initState();
    arguments = parseArguments(widget.response.arguments);
  }

  String? getAssetByName(String name) {
    for (var asset in widget.response.assets) {
      if (asset.name == name) {
        return asset.path;
      }
    }
    return null;
  }

  // can be abstracted out
  Widget renderSlidePreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [Image.asset(getAssetByName("main-chart") ?? "")],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alumnos reprobados",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 24),
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Image.file(File(widget.response.assets[0].path)),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      InputComponent(
                        label: "Unidad",
                        hint: "Ingrese la unidad a graficar",
                      ),
                      CheckboxListTile(
                        value: true,
                        onChanged: (value) {},
                        title: Text(
                          "Añadir leyenda de profesores que no subieron",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
