import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/input_component.dart';

class FailureSection extends StatefulWidget {
  StartReport_Response response;
  FailureSection({super.key, required this.response});

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
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
                  child: Image.file(File(widget.response.imagePath)),
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
