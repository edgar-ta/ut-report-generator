import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/api/hello_request.dart';
import 'package:ut_report_generator/components/home/home_page_header/widget.dart';
import 'package:ut_report_generator/components/home/home_page_header/state.dart';
import 'package:ut_report_generator/components/home/recent_slideshows/state.dart';
import 'package:ut_report_generator/components/home/startup_button/state.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/components/home/recent_slideshows/widget.dart';
import 'package:ut_report_generator/models/response/hello_request_response.dart';
import 'package:ut_report_generator/models/response/recent_slideshows_response.dart';
import 'package:ut_report_generator/models/response/report_preview.dart';
import 'package:ut_report_generator/models/slideshow_editor_request.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/api/report/self.dart' as slideshow_api;
import 'package:ut_report_generator/utils/wait_at_least.dart';

enum StartupOption { importZip, createVisualization, createReport }

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RecentSlideshowsState _recentSlideshowsState = RecentSlideshowsState(
    status: FutureStatus.pending,
    response: null,
  );

  HomePageHeaderState _homePageHeaderState = HomePageHeaderState(
    status: FutureStatus.pending,
    response: null,
    startupButtonState: StartupButtonState(
      isOpen: false,
      selectedValue: StartupOption.createReport,
    ),
  );

  Future<void> _loadStates() async {
    await Future.wait([
          waitAtLeast(
            Duration(seconds: 1),
            slideshow_api.getRecentSlideshows(identifier: null),
          ),
          waitAtLeast(Duration(seconds: 1), helloRequest()),
        ])
        .then((values) {
          final recentSlideshowsResponse =
              values[0] as RecentSlideshowsResponse;
          final helloRequestResponse = values[1] as HelloRequestResponse;
          setState(() {
            _recentSlideshowsState.response = recentSlideshowsResponse;
            _recentSlideshowsState.status = FutureStatus.success;
            _homePageHeaderState = _homePageHeaderState.copyWith(
              response: helloRequestResponse,
              status: FutureStatus.success,
            );
          });
        })
        .catchError((_) {
          setState(() {
            _recentSlideshowsState.response = null;
            _recentSlideshowsState.status = FutureStatus.error;
            _homePageHeaderState = _homePageHeaderState.copyWith(
              response: null,
              status: FutureStatus.error,
            );
          });
        });
  }

  Future<void> _retryToLoadRecentSlideshows() async {
    setState(() {
      _recentSlideshowsState.response = null;
      _recentSlideshowsState.status = FutureStatus.pending;
    });
    await _loadStates();
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
        callbackWhenReturning: _loadStates,
      ),
    );
  }

  void _selectFiles(
    bool allowMultiple,
    List<String> allowedExtensions,
    Future<Slideshow> Function(List<String>) callback,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
    );
    if (result != null) {
      var files = result.files.map((file) => file.path!).toList();
      if (!mounted) return;
      _openSlideshowEditor(
        SlideshowEditorRequest(
          startCallback: () => callback(files),
          callbackWhenReturning: _loadStates,
        ),
      );
    }
  }

  Future<void> _startSlideshow(StartupOption option) async {
    switch (option) {
      case StartupOption.createReport:
        if (!mounted) return;
        _openSlideshowEditor(
          SlideshowEditorRequest(
            startCallback: () => slideshow_api.startReport_withImageSlide(),
            callbackWhenReturning: _loadStates,
          ),
        );
        return;
      case StartupOption.importZip:
        _selectFiles(false, [".zip"], (files) async {
          return slideshow_api.importReport(rootDirectory: files[0]);
        });
        break;
      case StartupOption.createVisualization:
        _selectFiles(true, [".xls"], (files) async {
          return slideshow_api.startReport_withPivotTable(files);
        });
        break;
    }
  }

  Future<void> _openSlideshowEditor(SlideshowEditorRequest request) async {
    await context.push("/home/report-editor", extra: request);
  }

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: HomePageHeader(
              state: _homePageHeaderState,
              setStartupButtonState: (mapping) {
                setState(() {
                  _homePageHeaderState = _homePageHeaderState.copyWith(
                    response: _homePageHeaderState.response,
                    startupButtonState: mapping(
                      _homePageHeaderState.startupButtonState,
                    ),
                  );
                });
              },
              startSlideshow: _startSlideshow,
            ),
          ),
          RecentSlideshows(
            state: _recentSlideshowsState,
            retry: _retryToLoadRecentSlideshows,
            openPreview: _openSlideshowPreview,
          ),
        ],
      ),
    );
  }
}
