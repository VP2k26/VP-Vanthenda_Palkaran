import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'transition_utils.dart';

/// Centralized Page Transition Builders for GoRouter
class AppPageTransitions {
  AppPageTransitions._();

  /// Silky smooth slide + fade navigation transition (Standard page push)
  static CustomTransitionPage<T> slideAndFade<T>({
    required GoRouterState state,
    required Widget child,
    Offset beginOffset = const Offset(0.06, 0),
    Duration duration = AppTransitions.normal,
    Duration reverseDuration = const Duration(milliseconds: 200),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppTransitions.defaultCurve,
        );
        final secondaryCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.92).animate(secondaryCurve),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Subtle scale + fade transition (Ideal for Tabs / Modals / Dialogs)
  static CustomTransitionPage<T> fadeAndScale<T>({
    required GoRouterState state,
    required Widget child,
    double initialScale = 0.95,
    Duration duration = AppTransitions.normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppTransitions.defaultCurve,
        );

        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: initialScale, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  /// Bottom sheet drilldown transition (Sliding upwards into view)
  static CustomTransitionPage<T> bottomSheetUp<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = AppTransitions.medium,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppTransitions.defaultCurve,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
    );
  }
}
