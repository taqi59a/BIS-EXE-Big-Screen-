import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';

/// A frosted-glass card used throughout the display.
/// Gives a premium, modern feel with backdrop blur and subtle borders.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 18,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: BISLColors.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? BISLColors.glassBorder,
              width: 1.0,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A subtle gold-bordered variant for special content (quotes, word of the day).
class GoldGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GoldGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: BISLColors.schoolGold.withOpacity(0.3),
      padding: padding,
      child: child,
    );
  }
}
