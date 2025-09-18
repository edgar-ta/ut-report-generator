import 'package:flutter/material.dart';

const double APP_BAR_HEIGHT = 48;
const double MENU_WIDTH = 512;
double slideHeight(BuildContext context) {
  return MediaQuery.of(context).size.height - APP_BAR_HEIGHT * 2;
}
