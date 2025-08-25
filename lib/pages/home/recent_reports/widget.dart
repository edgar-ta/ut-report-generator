import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/report/get_report.dart';
import 'package:ut_report_generator/api/report/get_recent_reports.dart';
import 'package:ut_report_generator/pages/home/recent_reports/report_card.dart';
import 'package:ut_report_generator/pages/home/recent_reports/report_card_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

class RecentReports extends StatefulWidget {
  const RecentReports({super.key});

  @override
  State<RecentReports> createState() => _RecentReportsState();
}

class _RecentReportsState extends State<RecentReports> {
  RecentReports_Response? response;
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
    var isLoading = exception == null && response == null;
    var isSuccess = response != null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children:
            isSuccess
                ? [
                  Text(
                    "Reportes recientes".toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  (response!.reports.isNotEmpty
                      ? RecentReportsList(
                        isSuccess: isSuccess,
                        response: response,
                        mounted: mounted,
                        isLoading: isLoading,
                      )
                      : EmptyReportsPlaceholder()),
                ]
                : [
                  Text("No se pudieron obtener los reportes recientes"),
                  Text("(×_×)"),
                  TextButton(
                    onPressed: _fetchRecentReports,
                    child: Text("Reintentar"),
                  ),
                ],
      ),
    );
  }
}

class EmptyReportsPlaceholder extends StatelessWidget {
  const EmptyReportsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 148,
      child: Center(
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
      ),
    );
  }
}

class RecentReportsList extends StatelessWidget {
  const RecentReportsList({
    super.key,
    required this.isSuccess,
    required this.response,
    required this.mounted,
    required this.isLoading,
  });

  final bool isSuccess;
  final RecentReports_Response? response;
  final bool mounted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: Stack(
        children: [
          // Actual content
          AnimatedOpacity(
            opacity: isSuccess ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(
                dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: response?.reports.length ?? 0,
                itemBuilder: (context, index) {
                  final report = response!.reports[index];
                  return ReportCard(
                    name: report.name,
                    preview: report.preview,
                    onTap: () {
                      if (!mounted) return;
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
          ),

          AnimatedOpacity(
            opacity: isLoading ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: IgnorePointer(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => const ReportCardSkeleton(),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
