import 'package:flutter/material.dart';

const BLUE_COLOR = Color(0xFF002855);
const double APP_BAR_HEIGHT = 48;
const double MENU_WIDTH = 512;
double slideHeight(BuildContext context) {
  return MediaQuery.of(context).size.height - APP_BAR_HEIGHT * 2;
}

const double SLIDESHOW_PREVIEW_HEIGHT = 160;
