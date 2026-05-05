import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  // ── Title - Anuphan ────────────────────────────────────────────────
  static TextStyle fontTitleLargeProminent({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.1818, // 26 / 22
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontTitleLarge({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w400,
        fontSize: 22,
        height: 1.1818, // 26 / 22
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontTitleMediumProminent({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.2, // 24 / 20
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontTitleMedium({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        height: 1.2, // 24 / 20
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontTitleSmallProminent({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        height: 1.3333, // 24 / 18
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontTitleSmall({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        height: 1.2222, // 22 / 18
        color: color ?? AppColors.textPrimary,
      );

  // ── Body - Sarabun ────────────────────────────────────────────────
  static TextStyle fontBodyLargeProminent({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.625, // 26 / 16
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontBodyLarge({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.625, // 26 / 16
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontBodyMediumProminent({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.4286, // 20 / 14
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontBodyMedium({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.4286, // 20 / 14
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle fontBodySmallProminent({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.3333, // 16 / 12
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle fontBodySmall({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.3333, // 16 / 12
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle fontBodyExtraSmallProminent({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        height: 1.4, // 14 / 10
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle fontBodyExtraSmall({Color? color}) => GoogleFonts.sarabun(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        height: 1.4, // 14 / 10
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle fontLabelSansSerifTiny({Color? color}) => GoogleFonts.anuphan(
        fontWeight: FontWeight.w500,
        fontSize: 8,
        height: 1.6, // 14 / 10
        color: color ?? AppColors.textSecondary,
      );

  // ── Helpers ───────────────────────────────────────────────────────
  static TextStyle fontTitleMediumProminentPrimary() => fontTitleMediumProminent(color: AppColors.primary);
  static TextStyle fontTitleSmallProminentPrimary() => fontTitleSmallProminent(color: AppColors.primary);

  // ── ระบบ Theme Integration ────────────────────────────────────────
  static TextTheme createTextTheme() {
    return TextTheme(
      displayMedium: fontTitleLargeProminent(),
      headlineSmall: fontTitleMediumProminent(),
      titleLarge: fontTitleSmallProminent(),
      bodyLarge: fontBodyLarge(),
      bodyMedium: fontBodyMedium(),
      bodySmall: fontBodySmall(),
      labelLarge: fontBodyMediumProminent(color: Colors.white),
    );
  }
}
