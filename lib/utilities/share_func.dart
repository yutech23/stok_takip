import 'package:flutter/material.dart';

class ShareFunc {
  double getWidthScreenSize(BuildContext context) {
    late double widthMediaQuery;
    widthMediaQuery = MediaQuery.of(context).size.width < 500 ? 360 : 600;
    return widthMediaQuery;
  }
}

final shareFunc = ShareFunc();
