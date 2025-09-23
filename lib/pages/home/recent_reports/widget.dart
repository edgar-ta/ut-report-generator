import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/api/report/get_report.dart';
import 'package:ut_report_generator/api/report/get_recent_reports.dart';
import 'package:ut_report_generator/models/response/recent_reports_response.dart';
import 'package:ut_report_generator/models/response/report_preview.dart';
import 'package:ut_report_generator/pages/home/recent_reports/report_preview_card.dart';
import 'package:ut_report_generator/pages/home/recent_reports/report_card_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

class RecentReports extends StatefulWidget {
  const RecentReports({super.key});

  @override
  State<RecentReports> createState() => _RecentReportsState();
}

class _RecentReportsState extends State<RecentReports> {
  RecentReportsResponse? response;
  Object? exception;

  @override
  void initState() {
    super.initState();
    _fetchRecentReports();
  }

  Future<void> _fetchRecentReports() async {
    setState(() {
      response = null;
      exception = null;
    });

    return await waitAtLeast(
      Duration(seconds: 10),
      recentReports(identifier: null)
          .then((value) {
            setState(() {
              response = value;
              exception = null;
            });
          })
          .catchError((error) {
            setState(() {
              response = null;
              exception = error;
            });
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isError = exception != null;
    var isSuccess = response != null;
    var isLoading = exception == null && response == null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: SLIDESHOW_PREVIEW_HEIGHT + 50,
        child:
            isError
                ? _errorState()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 8,
                  children: [
                    Text(
                      "Reportes recientes".toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    (SizedBox(
                      height: SLIDESHOW_PREVIEW_HEIGHT,
                      child: Stack(
                        children: [
                          _reportPreviewSkeletons(isLoading),
                          isSuccess
                              ? _reportPreviews(isSuccess, response!, (
                                callback,
                              ) {
                                setState(() {
                                  response = callback(response!);
                                });
                              })
                              : EmptyReportsPlaceholder(),
                        ],
                      ),
                    )),
                  ],
                ),
      ),
    );
  }

  _reportPreviewSkeletons(bool isLoading) {
    return AnimatedOpacity(
      opacity: isLoading ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: IgnorePointer(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: 3,
          itemBuilder: (context, index) => const ReportCardSkeleton(),
          separatorBuilder: (_, __) => const SizedBox(width: 16),
        ),
      ),
    );
  }

  _reportPreviews(
    bool isSuccess,
    RecentReportsResponse response,
    void Function(RecentReportsResponse Function(RecentReportsResponse))
    setResponse,
  ) {
    return AnimatedOpacity(
      opacity: isSuccess ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: response.reports.length,
          shrinkWrap: true,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final report = response.reports[index];
            return ReportPreviewCard(
              key: ValueKey(report.identifier),
              name: report.name,
              preview: report.preview,
              lastOpen: report.lastOpen.relativeTimeLocale(Locale('es', 'MX')),
              onTap: () {
                if (!mounted) return;
                setResponse((response) {
                  final report = response.reports.removeAt(index);
                  report.lastOpen = DateTime.now();
                  response.reports.insert(0, report);
                  return response;
                });
                context.go(
                  "/home/report-editor",
                  extra: () => getReport(identifier: report.identifier),
                );
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 16),
        ),
      ),
    );
  }

  _errorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("No se pudieron obtener los reportes recientes"),
        Text("(×_×)"),
        TextButton(onPressed: _fetchRecentReports, child: Text("Reintentar")),
      ],
    );
  }
}

class EmptyReportsPlaceholder extends StatelessWidget {
  const EmptyReportsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              "Sin reportes recientes",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Tus reportes aparecerán aquí una vez sean generados",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
