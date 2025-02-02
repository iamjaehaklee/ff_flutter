import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.white; // 기본 색상
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color dividerColor = Color(0xFFDDDDDD);
  static const Color titleTextColor = Colors.black;
  static const Color descriptionTextColor = Colors.grey;
  static const Color chipBackgroundColor = Colors.white;
  static const Color chipTextColor = Colors.black;
  static const Color listEndBackgroundColor = Color(0xFF424242);
  static const Color listEndTextColor = Colors.white;
  static const Color appBarBottomBorderColor = Color(0xFFDDDDDD);
  static const Color interactiveTextColor = Colors.blueAccent; // 클릭 가능한 텍스트 색상





  // Chip Theme
  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: chipBackgroundColor,
    labelStyle: const TextStyle(fontSize: 12, color: chipTextColor),
    secondaryLabelStyle: const TextStyle(fontSize: 12, color: chipTextColor),
  );

  // AppBar Theme
  static AppBarTheme appBarTheme = const AppBarTheme(

    shadowColor: Colors.black45,
    surfaceTintColor: Colors.white,
    elevation: 1,
    toolbarHeight: 48.0,
     backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    iconTheme: IconThemeData(size: 20),
  );
  // ✅ Progress Indicator Theme (로딩 인디케이터 색상 설정)
  static ProgressIndicatorThemeData progressIndicatorTheme = ProgressIndicatorThemeData(
    color: Colors.blue, // ✅ CircularProgressIndicator 색상 변경
  );
// Text Field Theme
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200], // 입력 필드 배경색
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.blue, width: 2), // ✅ 포커스 시 테두리 색상 파란색
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    // ✅ 클릭 전 (라벨이 큰 글씨로 입력 필드 내부에 있을 때)
    labelStyle: const TextStyle(
      color: Colors.grey, // 진회색
      fontSize: 16, // 기본 크기
    ),

    // ✅ 클릭 후 (포커스 시 라벨이 작아지면서 위로 올라갈 때)
    floatingLabelStyle: const TextStyle(
      color: Colors.blue, // 파란색
      fontSize: 12, // 작아짐
    ),
  );
  // Checkbox Theme (Setting the color of the checkbox)
  static CheckboxThemeData checkboxTheme = CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white), // Checkmark color (white)
    fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          // When selected (checked), set background to blue
          return Colors.blue;
        }
        // When not selected (unchecked), set background to white
        return Colors.white;
      },
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
  // Button Theme
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );

  // Text Styles
  static const TextStyle defaultTextStyle = TextStyle(color: Colors.black);
  static const TextStyle interactiveTextStyle = TextStyle(
    color: interactiveTextColor,
    fontWeight: FontWeight.w500,
  );

  // 전체 ThemeData
  static ThemeData themeData = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.blue, // 기본 앱 테마 색상
      secondary: Colors.blue, // RefreshIndicator 색상
    ),

    primarySwatch: Colors.blue, // 앱 기본 색상 (파란색 계열)
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue, // FAB 색상을 파란색으로 설정
      foregroundColor: Colors.white, // 아이콘 색상을 흰색으로 설정
    ),    progressIndicatorTheme: progressIndicatorTheme, // ✅ 적용

    scaffoldBackgroundColor: scaffoldBackgroundColor,
    dividerColor: dividerColor,
    chipTheme: chipTheme,
    appBarTheme: appBarTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,    checkboxTheme: checkboxTheme, // Apply the Checkbox Theme here

  );
}
