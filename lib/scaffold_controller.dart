import 'package:flutter/material.dart';

class ScaffoldController extends ChangeNotifier {
  PreferredSizeWidget Function(BuildContext)? _appBarBuilder;
  PreferredSizeWidget Function(BuildContext)? get appBarBuilder =>
      _appBarBuilder;

  Widget Function(BuildContext)? _fabBuilder;
  Widget Function(BuildContext)? get fabBuilder => _fabBuilder;

  void setAppBarBuilder(
    PreferredSizeWidget Function(BuildContext)? appBarBuilder,
  ) {
    _appBarBuilder = appBarBuilder;
    notifyListeners();
  }

  void setFabBuilder(Widget Function(BuildContext)? fabBuilder) {
    _fabBuilder = fabBuilder;
    notifyListeners();
  }
}
