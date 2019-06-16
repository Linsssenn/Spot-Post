import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData themeData = _buildThemeData();

ThemeData _buildThemeData(){
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: Colors.white,
    primaryColor: black1,
    primaryColorDark: Colors.grey,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: black1,
      textTheme: ButtonTextTheme.normal,
    ),
    scaffoldBackgroundColor: backgroundWhite,
    cardColor: backgroundWhite,
    textSelectionColor: black1,
    errorColor: errorRed,
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    primaryIconTheme: base.iconTheme.copyWith(color: black2),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    )
  );
}
TextTheme _buildTextTheme(TextTheme base){
  return base.copyWith(
    headline: base.headline.copyWith(
      fontWeight: FontWeight.w500,
    ),
    title: base.title.copyWith(
      fontSize: 18.0
    ),
    caption: base.caption.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
    ),
  ).apply(
    fontFamily: 'Rubik',
    displayColor: black1,
    bodyColor: black1,
  );
}