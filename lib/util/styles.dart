import 'package:flutter/cupertino.dart';

// doing scales here as well
const double scaleFactor = 1 / 3;
const int originalFontSize = 50;
const int originalSqDimension = 1080;
const int originalDotSize = 10;
const int originalPaddingVertical = 120;
const int originalPaddingHorizontal = 66;

abstract class Styles {
  static double postFontSize = (originalFontSize * scaleFactor);
  static double sqDimension = (originalSqDimension * scaleFactor);
  static double dotSize = (originalDotSize * scaleFactor);
  static double paddingVertical = (originalPaddingVertical * scaleFactor);
  static double paddingHorizontal = (originalPaddingHorizontal * scaleFactor);
  static double invertScaleFactor = 1 / scaleFactor;

  static TextStyle comicSansText = TextStyle(
    fontFamily: 'Comic',
    fontSize: postFontSize,
    color: CupertinoColors.black,
  );

  static const TextStyle titleStyle = TextStyle(
    color: CupertinoColors.black,
    fontWeight: FontWeight.bold,
  );

  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static Color shadowGrey = CupertinoColors.systemGrey.withOpacity(0.5);
  static Color activeBlue = CupertinoColors.activeBlue.withOpacity(0.6);
}
