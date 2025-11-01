import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bg = isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight;
  final bgSecondary = isDark ? Tokens.bgSecondaryDark : Tokens.bgSecondaryLight;
  final card = isDark ? Tokens.cardDark : Tokens.cardLight;
  final text = isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight;
  final secondary = isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight;
  final purple = isDark ? Tokens.purpleDark100 : Tokens.purple100;
  final orange = isDark ? Tokens.orangeDark100 : Tokens.orange100;
  final blue = isDark ? Tokens.blueDark100 : Tokens.blue100;
  final green = isDark ? Tokens.greenDark100 : Tokens.green100;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: Tokens.brand,
    onPrimary: Colors.white,
    secondary: blue,
    onSecondary: Colors.white,
    surface: card,
    onSurface: text,
    background: bg,
    onBackground: text,
    error: Tokens.red100,
    onError: Colors.white,
    primaryContainer: isDark ? Tokens.purpleDark20 : Tokens.purple20,
    secondaryContainer: isDark ? Tokens.orangeDark20 : Tokens.orange20,
    tertiary: purple,
    tertiaryContainer: isDark ? Tokens.greenDark20 : Tokens.green20,
    surfaceContainerHighest: card,
    surfaceContainerLow: card,
    surfaceTint: Colors.transparent,
    outline: Tokens.gray40,
    outlineVariant: Tokens.gray20,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    cardColor: card,
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: text,
      centerTitle: false,
      systemOverlayStyle: isDark 
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: text, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: text, fontSize: 16),
      bodyMedium: TextStyle(color: text, fontSize: 14),
      bodySmall: TextStyle(color: secondary, fontSize: 12),
      labelLarge: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: secondary, fontSize: 10, fontWeight: FontWeight.w500),
    ),
    
    // Divider
    dividerColor: Tokens.gray20,
    dividerTheme: DividerThemeData(
      color: Tokens.gray20,
      thickness: 1,
      space: 1,
    ),
    
    // Icon
    iconTheme: IconThemeData(color: secondary, size: 24),
    
    // Card
    cardTheme: CardTheme(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // ListTile
    listTileTheme: ListTileThemeData(
      tileColor: card,
      textColor: text,
      iconColor: secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Tokens.gray20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Tokens.gray20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Tokens.brand, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Tokens.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Tokens.brand,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: Tokens.gray40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: bg,
      elevation: 0,
    ),
    
    // BottomSheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    
    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
