import 'package:flutter/material.dart';

/// Centralized curves, durations, and motion constants for the Vanthenda-Paalkaran app
class AppTransitions {
  AppTransitions._();

  // ── Standard Durations ────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 800);

  // ── Standard Curves ───────────────────────────────────────────────────────
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve smoothInCurve = Curves.easeInCubic;
  static const Curve unfoldCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;

  // ── Color Tokens for Transitions ──────────────────────────────────────────
  static const Color darkBrown = Color(0xFF3D2314);
  static const Color mediumBrown = Color(0xFF5A3E2B);
  static const Color warmGold = Color(0xFFFFF3AB);
  static const Color creamBg = Color(0xFFFAF6EE);
  static const Color cardBorder = Color(0x334A2E18);
  static const Color scrimColor = Color(0x403D2314);
}
