import 'package:flutter/material.dart';

Color primary = Color(0xFF59CC47);

class Styles {
  static Color primaryColor = primary;
  static Color primaryAccent = const Color(0xFF3D8F31);
  static Color secondaryColor = const Color(0xFF212420);
  static Color secondaryAccent = const Color(0xFF3A4039);
  static Color bgColor = const Color(0xFFF5F5F5);
  static Color warningColor = const Color(0xFFF0932B);
  static Color dangerColor = const Color(0xFFEB4D4B);
  static Color successColor = const Color(0xFF2ECC71);
  static Color infoColor = const Color(0xFF0ABDE3);
  // static Color fontColor = const Color(0xFF10161C);
  static Color fontColor = const Color(0xFFF5F5F5);
  static Color fontSecondaryColor = const Color(0xFF59CC47);
  // static Color fontAlternativeColor = const Color(0xFFF7D125);
  static Color fontColorLight = const Color(0xFFD4D4D4);
  static Color fontDarkColor = const Color(0xFF232426);
  static Color fontDarkColorLight = const Color(0xFF47494D);
  static Color fontColorWhite = const Color(0xFFF5F5F5);
  static Color shadowColor = const Color(0xFFB5B4B3);

//   Font Styles
  static TextStyle defaultFont = TextStyle(fontSize: 16, color: fontColorLight);
  static TextStyle titleFont = TextStyle(
      fontSize: 26, color: fontDarkColor, fontWeight: FontWeight.bold);
  static TextStyle titleSecondaryFont = TextStyle(
      fontSize: 26, color: fontSecondaryColor, fontWeight: FontWeight.bold);
  static TextStyle titleDarkFont = TextStyle(
      fontSize: 26, color: fontColor, fontWeight: FontWeight.bold);
  static TextStyle subTitleFont = TextStyle(
      fontSize: 14, color: fontColorLight, fontWeight: FontWeight.w300);
  static TextStyle subTitleDarkFont = TextStyle(
      fontSize: 14, color: fontDarkColorLight, fontWeight: FontWeight.w600);
  static TextStyle subTitleSecondaryFont = TextStyle(
    fontSize: 14,
    color: fontSecondaryColor,
    fontWeight: FontWeight.w300,
  );
}
