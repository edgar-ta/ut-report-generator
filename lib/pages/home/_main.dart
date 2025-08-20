import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/api/hello_request.dart';
import 'package:ut_report_generator/api/import_report.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/models/report_class.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/main_app/route_observer.dart';
import 'package:ut_report_generator/pages/home/file_picker_button2.dart';
import 'package:ut_report_generator/pages/home/recent_reports/widget.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/scaffold_controller.dart';

Future<ReportClass> _createNewReport(List<File> files) async {
  return startReport(files.map((file) => file.absolute.path).toList());
}

Future<ReportClass> _importReportFromZip(List<File> files) async {
  return importReport(reportFile: files[0].absolute.path);
}

enum PossibleOption {
  createNewReport(
    displayName: "Crear nuevo reporte",
    icon: Icon(Icons.add),
    callback: _createNewReport,
    allowMultiple: true,
    allowedExtensions: ["xls"],
  ),
  importReportFromZip(
    displayName: "Importar reporte",
    icon: Icon(Icons.file_open),
    callback: _importReportFromZip,
    allowMultiple: false,
    allowedExtensions: ["zip"],
  );

  final String displayName;
  final Widget icon;
  final Future<ReportClass> Function(List<File> files) callback;
  final bool allowMultiple;
  final List<String> allowedExtensions;

  const PossibleOption({
    required this.displayName,
    required this.icon,
    required this.callback,
    required this.allowMultiple,
    required this.allowedExtensions,
  });
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  PossibleOption selectedValue = PossibleOption.createNewReport;

  Future<void> _openReportEditor(PossibleOption possibleOption) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: possibleOption.allowMultiple,
      allowedExtensions: possibleOption.allowedExtensions,
    );
    if (result != null) {
      var files = result.files.map((file) => File(file.path!)).toList();
      if (!mounted) return;
      context.go(
        "/home/report-editor",
        extra: () => possibleOption.callback(files),
      );
    }
  }

  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ScaffoldController>()
      ..setFab(null)
      ..setAppBarBuilder(null);
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenLoadingOverlay(
      callback: helloRequest,
      errorScreen: ErrorPage(),
      loadingScreen: LoadingPage(
        messages: [
          "Conectando con el servidor",
          "Abriendo la base de datos",
          "Pensando",
          "Preguntándole a ChatGPT",
          "Calentando motores",
        ],
        title: "Conectando con el servidor",
      ),
      builder:
          (helloRequestResponse) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Text(
                        helloRequestResponse.message,
                        style: TextStyle(fontSize: 32),
                      ),
                      FilePickerButton2(
                        values: PossibleOption.values,
                        selectedValue: selectedValue,
                        itemBuilder:
                            (option, _) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                spacing: 8,
                                children: [
                                  option.icon,
                                  Text(option.displayName),
                                ],
                              ),
                            ),
                        onTriggerPressed:
                            (value) async => _openReportEditor(value),
                        triggerBuilder:
                            (option) => SizedBox(
                              width: 130,
                              child: Text(option.displayName),
                            ),
                        onItemSelected: (value) async {
                          setState(() {
                            selectedValue = value;
                          });
                          _openReportEditor(value);
                        },
                      ),
                    ],
                  ),
                ),
                RecentReports(),
              ],
            ),
          ),
    );
  }
}
