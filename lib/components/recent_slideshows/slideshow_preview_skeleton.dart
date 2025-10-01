import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class SlideshowPreviewSkeleton extends StatefulWidget {
  const SlideshowPreviewSkeleton({super.key});

  @override
  State<SlideshowPreviewSkeleton> createState() =>
      _SlideshowPreviewSkeletonState();
}

class _SlideshowPreviewSkeletonState extends State<SlideshowPreviewSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerPosition;

  @override
  void initState() {
    super.initState();

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
    return AnimatedBuilder(
      animation: _shimmerPosition,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
          ),
          height: SLIDESHOW_PREVIEW_HEIGHT,
          width: SLIDESHOW_PREVIEW_HEIGHT * 16 / 9,
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base shimmer background
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
                  child: Container(color: Colors.white),
                ),
              ),

              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 28,
                  color: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
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
