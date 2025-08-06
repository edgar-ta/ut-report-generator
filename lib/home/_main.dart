import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/server_connection_loader/widget.dart';
import 'package:ut_report_generator/home/file_picker_button.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';

class HomePage extends StatefulWidget {
  String? message;
  HomePage({super.key, this.message});

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Text(
                widget.message ?? "Bienvenido, profesor",
                style: TextStyle(fontSize: 32),
              ),
              FilePickerButton(
                onFileSelected: (filePath) async {
                  setState(() {
                    isLoading = true;
                  });

                  await startReport(filePath)
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
                                (context) =>
                                    ReportEditor(response: responseData),
                          ),
                        );
                      })
                      .catchError((error) {
                        print("Something went wrong with the request");
                        print(error);
                        setState(() {
                          isLoading = false;
                          errorMessage = "Hubo un error al cargar el archivo";
                        });
                      });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "Reportes recientes".toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 148,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(color: Colors.blue),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 16);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
