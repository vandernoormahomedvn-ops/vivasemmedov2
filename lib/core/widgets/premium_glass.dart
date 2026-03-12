import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable, ultra-premium Liquid Glass / PremiumGlass container.
///
/// Features heavy blur, specular highlights, linear gradient, and a seamless
/// noise texture overlay to simulate authentic physical glass.
class PremiumGlass extends StatelessWidget {
  const PremiumGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = EdgeInsets.zero,
    this.blurSigma = 24.0, // Heavy blur for realism
    this.borderOpacity = 0.2, // Subtle border
    this.gradientOpacityStart = 0.15,
    this.gradientOpacityEnd = 0.05,
    this.noiseOpacity = 0.04, // Subtle noise multiplier
    this.margin,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final double borderOpacity;
  final double gradientOpacityStart;
  final double gradientOpacityEnd;
  final double noiseOpacity;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // In dark mode, white glass works well. In light mode, maybe white glass too, or a hint of surface color.
    final baseColor = Colors.white;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Stack(
              children: [
                // The main glass body (Linear Gradient)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor.withValues(alpha: gradientOpacityStart),
                          baseColor.withValues(alpha: gradientOpacityEnd),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),

                // Actual content
                Padding(padding: padding, child: child),

                // Elevated Specular Border
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: borderOpacity),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
