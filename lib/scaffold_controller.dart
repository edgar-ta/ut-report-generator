import 'package:flutter/material.dart';

class ScaffoldController extends ChangeNotifier {
  Widget? _fab;
  Widget? get fab => _fab;

  void setFab(Widget? fab) {
    _fab = fab;
    notifyListeners();
  }

  PreferredSizeWidget Function(BuildContext context)? _appBarBuilder;
  PreferredSizeWidget Function(BuildContext context)? get appBarBuilder =>
      _appBarBuilder;

  void setAppBarBuilder(
    PreferredSizeWidget Function(BuildContext context)? appBarBuilder,
  ) {
    _appBarBuilder = appBarBuilder;
    notifyListeners();
  }
}
