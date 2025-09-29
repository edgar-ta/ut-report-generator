import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class ShimmerSlide extends StatefulWidget {
  const ShimmerSlide({super.key});

  @override
  State<ShimmerSlide> createState() => _ShimmerSlideState();
}

class _ShimmerSlideState extends State<ShimmerSlide>
    with SingleTickerProviderStateMixin {
  late int randomMode;

  late AnimationController _controller;
  late Animation<double> _shimmerPosition;

  @override
  void initState() {
    super.initState();
    randomMode = Random().nextInt(2);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _shimmerPosition = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = slideHeight(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: screenHeight,
      width: double.infinity,
      child:
          randomMode == 0 ? _buildPseudoCover(theme) : _buildPseudoCover(theme),
    );
  }

  /// Pseudo gráfico con shimmer solo de fondo
  Widget _buildPseudoChart(ThemeData theme) {
    final random = Random();
    final bars = List.generate(6, (index) => random.nextInt(200) + 100);

    return AnimatedBuilder(
      animation: _shimmerPosition,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo animado shimmer
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.4, 0.5, 0.6],
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade100,
                        Colors.grey.shade300,
                      ],
                      transform: GradientTranslation(
                        _shimmerPosition.value * bounds.width,
                      ),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Container(
                    color: theme.colorScheme.surfaceContainerLow,
                  ),
                ),
              ),
              // Contenido estático encima del fondo
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título del gráfico
                  Container(
                    height: 48,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Líneas horizontales
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(10, (index) {
                              return Container(
                                height: 1,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.1,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              );
                            }),
                          ),
                        ),
                        // Barras
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:
                                bars.map((value) {
                                  return Container(
                                    width: 80,
                                    height: value.toDouble(),
                                    color: theme.colorScheme.primaryFixedDim,
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pseudo portada con shimmer solo de fondo
  Widget _buildPseudoCover(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerPosition,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo animado shimmer
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.4, 0.5, 0.6],
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade100,
                        Colors.grey.shade300,
                      ],
                      transform: GradientTranslation(
                        _shimmerPosition.value * bounds.width,
                      ),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Container(
                    color: theme.colorScheme.surfaceContainerLow,
                  ),
                ),
              ),
              // Contenido estático encima
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    height: 28,
                    width: 200,
                    color: theme.colorScheme.primaryFixedDim,
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
                  Container(
                    height: 20,
                    width: 120,
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    margin: const EdgeInsets.only(bottom: 24),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 16,
                      width: 80,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (_) {
                        return Container(
                          height: 20,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom translation transform for the shimmer effect
class GradientTranslation extends GradientTransform {
  final double dx;
  GradientTranslation(this.dx);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}
