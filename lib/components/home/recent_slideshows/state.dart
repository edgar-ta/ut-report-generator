import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/response/recent_slideshows_response.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class RecentSlideshowsState {
  FutureStatus status;
  RecentSlideshowsResponse? response;
  GlobalKey<AnimatedListState> listKey;

  RecentSlideshowsState({
    required this.status,
    this.response,
    required this.listKey,
  });
}
