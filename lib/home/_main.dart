import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              File file = File(result.files.single.path!);
              setState(() {
                isLoading = true;
              });

              await startReport(file.absolute.path)
                  .then((response) {
                    setState(() {
                      isLoading = false;
                    });
                    var responseBody = jsonDecode(response.body);
                    var responseData = StartReport_Response.fromJson(
                      responseBody,
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReportEditor(response: responseData),
                      ),
                    );
                  })
                  .catchError((error) {
                    setState(() {
                      isLoading = false;
                      errorMessage = "Hubo un error al cargar el archivo";
                    });
                  });
            }
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
