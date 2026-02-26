import 'package:flutter/material.dart';
import 'package:holy_quran/values/font_manager.dart';
TextStyle _getTextStyle(double fontSize, String fontFamily,
    FontWeight fontWeight, Color fontColor) {
  return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      color: fontColor);
}
TextStyle getThinStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.thin, color);
}
TextStyle getExtraLightStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.extraLight, color);
}
TextStyle getLightStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.ligth, color);
}
TextStyle getReqularStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.reqular, color);
}
TextStyle getMediumStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.medium, color);
}
TextStyle getBoldStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.bold, color);
}
TextStyle getSemiBoldStyle({double fontSize = 12, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.semiBold, color);
}
TextStyle getExtraBoldStyle({fontSize, color}) {
  return _getTextStyle(
      fontSize, FontManager.fontFamily, FontWeightManager.extraBold, color);
}
