import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/api/slideshow/get_slideshow.dart';
import 'package:ut_report_generator/api/slideshow/get_recent_slideshows.dart';
import 'package:ut_report_generator/components/home/recent_slideshows/state.dart';
import 'package:ut_report_generator/models/response/recent_slideshows_response.dart';
import 'package:ut_report_generator/models/response/report_preview.dart';
import 'package:ut_report_generator/components/home/recent_slideshows/slideshow_preview_card.dart';
import 'package:ut_report_generator/components/home/recent_slideshows/slideshow_preview_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

class RecentSlideshows extends StatefulWidget {
  RecentSlideshowsState state;
  void Function(SlideshowPreview) openPreview;
  Future<void> Function(SlideshowPreview)? deletePreview;
  Future<void> Function()? retry;

  RecentSlideshows({
    super.key,
    required this.state,
    required this.openPreview,
    this.retry,
    this.deletePreview,
  });

  @override
  State<RecentSlideshows> createState() => _RecentSlideshowsState();
}

class _RecentSlideshowsState extends State<RecentSlideshows> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SLIDESHOW_PREVIEW_HEIGHT + 64,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child:
          widget.state.status == FutureStatus.error
              ? _errorState(widget.retry)
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 8,
                children: [
                  Text(
                    "Reportes recientes".toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: SLIDESHOW_PREVIEW_HEIGHT,
                    child: Stack(
                      children: [
                        _loadingState(
                          widget.state.status == FutureStatus.pending ? 1 : 0,
                        ),
                        if (widget.state.response != null)
                          widget.state.response!.reports.isNotEmpty
                              ? _successState(
                                widget.state.status == FutureStatus.success
                                    ? 1
                                    : 0,
                                widget.state.response!,
                                widget.openPreview,
                                widget.deletePreview,
                              )
                              : EmptyReportsPlaceholder(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  _loadingState(double opacity) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: IgnorePointer(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: 3,
          itemBuilder: (context, index) => const SlideshowPreviewSkeleton(),
          separatorBuilder: (_, __) => const SizedBox(width: 16),
        ),
      ),
    );
  }

  _successState(
    double opacity,
    RecentSlideshowsResponse response,
    void Function(SlideshowPreview) openPreview,
    Future<void> Function(SlideshowPreview)? deletePreview,
  ) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        child: AnimatedList.separated(
          key: widget.state.listKey,
          scrollDirection: Axis.horizontal,
          initialItemCount: widget.state.response!.reports.length,
          removedSeparatorBuilder: (context, index, animation) {
            return const SizedBox(width: 16);
          },
          separatorBuilder: (context, index, animation) {
            return const SizedBox(width: 16);
          },
          shrinkWrap: true,
          clipBehavior: Clip.none,
          itemBuilder: (context, index, animation) {
            final report = response.reports[index];
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(opacity: animation.value, child: child);
              },
              child: SlideshowPreviewCard(
                key: ValueKey(report.identifier),
                name: report.name,
                preview: report.preview,
                lastOpen: report.lastOpen.relativeTimeLocale(
                  Locale('es', 'MX'),
                ),
                openPreview: () {
                  openPreview(report);
                },
                deletePreview: () async {
                  await deletePreview?.call(report);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  _errorState(Future<void> Function()? retry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("No se pudieron obtener los reportes recientes"),
        Text("(×_×)"),
        TextButton(onPressed: retry, child: Text("Reintentar")),
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
