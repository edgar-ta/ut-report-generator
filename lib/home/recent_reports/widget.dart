import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/get_report.dart';
import 'package:ut_report_generator/api/recent_reports.dart';
import 'package:ut_report_generator/home/recent_reports/report_card.dart';
import 'package:ut_report_generator/home/recent_reports/report_card_skeleton.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';
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
      Duration(seconds: 5),
      recentReports(referenceReport: null)
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
    var isError = exception != null;
    var isSuccess = response != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children:
            isError
                ? [
                  Text("No se pudieron obtener los reportes recientes"),
                  Text("(×_×)"),
                  TextButton(
                    onPressed: _fetchRecentReports,
                    child: Text("Reintentar"),
                  ),
                ]
                : [
                  Text(
                    "Reportes recientes".toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 148,
                    child: Stack(
                      children: [
                        // Actual content
                        AnimatedOpacity(
                          opacity: isSuccess ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
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
                                    extra:
                                        () => getReport(
                                          reportDirectory: report.rootDirectory,
                                        ),
                                  );
                                },
                              );
                            },
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 16),
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
                              itemBuilder:
                                  (context, index) =>
                                      const ReportCardSkeleton(),
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
      ),
    );
  }
}
