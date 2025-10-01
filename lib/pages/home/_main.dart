import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/api/hello_request.dart';
import 'package:ut_report_generator/api/report/import_report.dart';
import 'package:ut_report_generator/api/report/start_report_with_image_slide.dart';
import 'package:ut_report_generator/api/report/start_report_with_pivot_table.dart';
import 'package:ut_report_generator/components/recent_slideshows/slideshow_preview_card.dart';
import 'package:ut_report_generator/components/recent_slideshows/state.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/main_app/route_observer.dart';
import 'package:ut_report_generator/components/file_picker_button2.dart';
import 'package:ut_report_generator/components/recent_slideshows/widget.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/models/response/report_preview.dart';
import 'package:ut_report_generator/models/slideshow_editor_request.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/api/report/self.dart' as slideshow_api;
import 'package:ut_report_generator/utils/wait_at_least.dart';

Future<Slideshow> _createNewVisualization(List<File> files) async {
  return startReport_withPivotTable(
    files.map((file) => file.absolute.path).toList(),
  );
}

Future<Slideshow> _importReportFromZip(List<File> files) async {
  return importReport(identifier: files[0].absolute.path);
}

enum PossibleOption {
  createNewVisualization(
    displayName: "Crear visualización",
    icon: Icon(Icons.add),
  ),
  createNewReport(
    displayName: "Crear reporte",
    icon: Icon(Icons.document_scanner),
  ),
  importReportFromZip(
    displayName: "Importar reporte",
    icon: Icon(Icons.file_open),
  );

  final String displayName;
  final Widget icon;

  const PossibleOption({required this.displayName, required this.icon});
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PossibleOption selectedValue = PossibleOption.createNewVisualization;
  final RecentSlideshowsState _recentSlideshowsState = RecentSlideshowsState(
    status: FutureStatus.pending,
    response: null,
  );

  Future<void> _loadRecentSlideshows() async {
    await waitAtLeast(
      Duration(seconds: 5),
      slideshow_api
          .getRecentSlideshows(identifier: null)
          .then((value) {
            setState(() {
              _recentSlideshowsState.response = value;
              _recentSlideshowsState.status = FutureStatus.success;
            });
          })
          .catchError((error) {
            setState(() {
              _recentSlideshowsState.response = null;
              _recentSlideshowsState.status = FutureStatus.error;
            });
          }),
    );
  }

  Future<void> _retryToLoadRecentSlideshows() async {
    setState(() {
      _recentSlideshowsState.response = null;
      _recentSlideshowsState.status = FutureStatus.pending;
    });
    await _loadRecentSlideshows();
  }

  Future<void> _openSlideshowPreview(SlideshowPreview preview) async {
    if (!mounted) return;
    setState(() {
      _recentSlideshowsState.response!.reports.removeWhere(
        (innerPreview) => innerPreview.identifier == preview.identifier,
      );
      _recentSlideshowsState.response!.reports.insert(
        0,
        preview..lastOpen = DateTime.now(),
      );
    });
    _openSlideshowEditor(
      SlideshowEditorRequest(
        startCallback:
            () => slideshow_api.getSlideshow(identifier: preview.identifier),
        callbackWhenReturning: _loadRecentSlideshows,
      ),
    );
  }

  Future<void> _startSlideshowWizard(PossibleOption possibleOption) async {
    if (possibleOption == PossibleOption.createNewReport) {
      if (!mounted) return;
      context.go(
        "/home/report-editor",
        extra: () => startReport_withImageSlide(),
      );
      return;
    }

    var allowMultipleFiles = true;
    var allowedExtensions = ["xlsx"];
    var callback = _createNewVisualization;

    if (possibleOption == PossibleOption.importReportFromZip) {
      allowMultipleFiles = false;
      allowedExtensions = ["zip"];
      callback = _importReportFromZip;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultipleFiles,
      allowedExtensions: allowedExtensions,
    );
    if (result != null) {
      var files = result.files.map((file) => File(file.path!)).toList();
      if (!mounted) return;
      _openSlideshowEditor(
        SlideshowEditorRequest(
          startCallback: () => callback(files),
          callbackWhenReturning: _loadRecentSlideshows,
        ),
      );
    }
  }

  Future<void> _openSlideshowEditor(SlideshowEditorRequest request) async {
    await context.push("/home/report-editor", extra: request);
  }

  @override
  void initState() {
    super.initState();
    _loadRecentSlideshows();
  }

  @override
  void dispose() {
    super.dispose();
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
                            (value) async => _startSlideshowWizard(value),
                        triggerBuilder:
                            (option) => SizedBox(
                              width: 130,
                              child: Text(option.displayName),
                            ),
                        onItemSelected: (value) async {
                          setState(() {
                            selectedValue = value;
                          });
                          _startSlideshowWizard(value);
                        },
                      ),
                    ],
                  ),
                ),
                RecentSlideshows(
                  state: _recentSlideshowsState,
                  retry: _retryToLoadRecentSlideshows,
                  openPreview: _openSlideshowPreview,
                ),
              ],
            ),
          ),
    );
  }
}
