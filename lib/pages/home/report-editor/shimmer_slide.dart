import 'package:flutter/material.dart';

class ShimmerSlide extends StatefulWidget {
  const ShimmerSlide({super.key});

  @override
  State<ShimmerSlide> createState() => _ShimmerSlideState();
}

class _ShimmerSlideState extends State<ShimmerSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shimmerSize = bounds.width;
            final shimmerPosition = _controller.value * shimmerSize * 2;

            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.4, 0.5, 0.6],
              begin: Alignment(-1.0 - 0.3 + shimmerPosition / shimmerSize, 0),
              end: Alignment(1.0 + 0.3 + shimmerPosition / shimmerSize, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: _buildCard(baseColor),
        );
      },
    );
  }

  Widget _buildCard(Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulación de título
            Container(height: 20, width: 120, color: color),
            const SizedBox(height: 16),
            // Simulación de gráfico con barras
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                return Container(
                  width: 20,
                  height: (index + 2) * 15.0,
                  color: color,
                );
              }),
            ),
            const SizedBox(height: 16),
            // Simulación de pie de card
            Container(height: 14, width: double.infinity, color: color),
          ],
        ),
      ),
    );
  }
}
