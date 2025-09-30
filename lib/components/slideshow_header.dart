import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/blocs/report_bloc.dart';
import 'package:ut_report_generator/components/invisible_text_field.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/report/visualization_mode.dart';

class SlideshowHeader extends StatefulWidget {
  const SlideshowHeader({super.key, required this.report, required this.bloc});

  final Slideshow report;
  final SlideshowEditorBloc bloc;

  @override
  State<SlideshowHeader> createState() => _SlideshowHeaderState();
}

class _SlideshowHeaderState extends State<SlideshowHeader> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.report.reportName);
  }

  void _onReportNameChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.bloc.rename(text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            "Creado ${widget.report.creationDate.relativeTimeLocale(Locale("es", "MX"))}",
          ),
          InvisibleTextField(
            controller: _controller,
            style: TextStyle(fontSize: 36),
            textAlign: TextAlign.center,
            onChanged: _onReportNameChanged,
          ),
          SegmentedButton(
            onSelectionChanged: (_) async {
              await widget.bloc.toggleSlideshowMode();
            },
            segments: [
              ButtonSegment(
                value: VisualizationMode.asReport,
                icon: Icon(Icons.edit_document),
              ),
              ButtonSegment(
                value: VisualizationMode.chartsOnly,
                icon: Icon(Icons.bar_chart),
              ),
            ],
            selected: {widget.report.visualizationMode},
          ),
        ],
      ),
    );
  }
}
