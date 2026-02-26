import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holy_quran/values/style_manager.dart';
import 'package:holy_quran/values/values_manager.dart';
import 'color_manager.dart';
import 'font_manager.dart';
class ThemeManager {
  static ThemeData getApplicationLightTheme() {
    return ThemeData(
      
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary: ColorManager.primary,
        secondary: ColorManager.secondary,
      ),
      primaryColor: ColorManager.primary,
      primaryColorLight: ColorManager.primary,
      primaryColorDark: ColorManager.secondary,
      disabledColor: ColorManager.grey,
      scaffoldBackgroundColor: ColorManager.white,
      splashColor: ColorManager.lightPrimary,
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      iconTheme: IconThemeData(color: ColorManager.primary),
      cardTheme: CardThemeData(
        color: ColorManager.white,
        shadowColor: ColorManager.grey,
        elevation: AppSize.s4,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        centerTitle: true,
        backgroundColor: ColorManager.white,
        elevation: AppSize.s2,
        shadowColor: Colors.transparent,
        titleTextStyle: getReqularStyle(
          fontSize: FontSizeManager.s16,
          color: ColorManager.white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: const StadiumBorder(),
        splashColor: ColorManager.grey,
        buttonColor: ColorManager.primary,
        disabledColor: ColorManager.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: getReqularStyle(
            color: ColorManager.white,
            fontSize: FontSizeManager.s16,
          ),
          backgroundColor: ColorManager.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FontSizeManager.s12),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: getSemiBoldStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s30,
        ),
        headlineLarge: getSemiBoldStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s24,
        ),
        headlineMedium: getReqularStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s16,
        ),
        titleLarge: getMediumStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s22,
        ),
        titleMedium: getMediumStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s16,
        ),
        bodyLarge: getBoldStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s24,
        ),
        bodyMedium: getReqularStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s14,
        ),
        bodySmall: getReqularStyle(
          color: ColorManager.grey,
          fontSize: FontSizeManager.s12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.transparent,
        filled: true,
        hintStyle: getReqularStyle(
          color: ColorManager.grey,
          fontSize: FontSizeManager.s14,
        ),
        labelStyle: getMediumStyle(
          color: ColorManager.black,
          fontSize: FontSizeManager.s14,
        ),
        errorStyle: getReqularStyle(
          color: ColorManager.red,
          fontSize: FontSizeManager.s14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(color: ColorManager.red, width: AppSize.s2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s2,
          ),
        ),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(ColorManager.secondary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(ColorManager.white),
      ),
    );
  }
  static ThemeData getApplicationDarkTheme() {
    return ThemeData(
      
      useMaterial3: false,
      iconTheme: IconThemeData(color: ColorManager.secondary),
      colorScheme: ColorScheme.dark(
        primary: ColorManager.secondary,
        secondary: ColorManager.secondary,
      ),
      primaryColor: ColorManager.secondary,
      primaryColorLight: ColorManager.primary,
      primaryColorDark: ColorManager.secondary,
      disabledColor: ColorManager.grey,
      scaffoldBackgroundColor: ColorManager.darkGrey,
      splashColor: ColorManager.lightPrimary,
      
      cardTheme: CardThemeData(
        color: ColorManager.black,
        shadowColor: ColorManager.grey,
        elevation: AppSize.s4,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        centerTitle: true,
        backgroundColor: ColorManager.primary,
        elevation: AppSize.s2,
        shadowColor: ColorManager.lightGrey,
        titleTextStyle: getReqularStyle(
          fontSize: FontSizeManager.s16,
          color: ColorManager.black,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: const StadiumBorder(),
        splashColor: ColorManager.grey,
        buttonColor: ColorManager.primary,
        disabledColor: ColorManager.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: getReqularStyle(
            color: ColorManager.white,
            fontSize: FontSizeManager.s16,
          ),
          backgroundColor: ColorManager.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FontSizeManager.s12),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: getSemiBoldStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s30,
        ),
        headlineLarge: getSemiBoldStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s24,
        ),
        headlineMedium: getReqularStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s16,
        ),
        titleLarge: getReqularStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s22,
        ),
        titleMedium: getMediumStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s16,
        ),
        bodyLarge: getBoldStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s24,
        ),
        bodyMedium: getReqularStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s14,
        ),
        bodySmall: getReqularStyle(
          color: ColorManager.secondary,
          fontSize: FontSizeManager.s12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[400],
        filled: true,
        hintStyle: getReqularStyle(
          color: ColorManager.white,
          fontSize: FontSizeManager.s14,
        ),
        labelStyle: getMediumStyle(
          color: ColorManager.white,
          fontSize: FontSizeManager.s14,
        ),
        errorStyle: getReqularStyle(
          color: ColorManager.red,
          fontSize: FontSizeManager.s14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(color: ColorManager.grey, width: AppSize.s1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(color: ColorManager.red, width: AppSize.s2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b32),
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s2,
          ),
        ),
      ),
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(ColorManager.secondary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(ColorManager.white),
      ),
    );
  }
}
