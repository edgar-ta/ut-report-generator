import 'package:flutter/material.dart';

class ScaffoldController extends ChangeNotifier {
  Widget? _fab;
  Widget? get fab => _fab;

  void setFab(Widget? fab) {
    _fab = fab;
    notifyListeners();
  }

  PreferredSizeWidget Function(BuildContext)? _appBarBuilder;
  PreferredSizeWidget Function(BuildContext)? get appBarBuilder =>
      _appBarBuilder;

  void setAppBarBuilder(
    PreferredSizeWidget Function(BuildContext)? appBarBuilder,
  ) {
    _appBarBuilder = appBarBuilder;
    notifyListeners();
  }
}
