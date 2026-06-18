// lib/views/shared/shimmer_loading.dart
import 'package:flutter/material.dart';

class ShimmerLoadingCard extends StatefulWidget {
  const ShimmerLoadingCard({super.key});

  @override
  State<ShimmerLoadingCard> createState() => _ShimmerLoadingCardState();
}

class _ShimmerLoadingCardState extends State<ShimmerLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerGradient = LinearGradient(
      colors: [
        Colors.grey.shade200,
        Colors.grey.shade100,
        Colors.grey.shade200,
      ],
      stops: const [0.1, 0.5, 0.9],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildShimmerBox(width: 40, height: 40, borderRadius: 10, gradient: shimmerGradient),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerBox(width: 120, height: 16, gradient: shimmerGradient),
                            const SizedBox(height: 6),
                            _buildShimmerBox(width: 80, height: 12, gradient: shimmerGradient),
                          ],
                        ),
                      ),
                      _buildShimmerBox(width: 60, height: 20, borderRadius: 12, gradient: shimmerGradient),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildShimmerBox(width: double.infinity, height: 14, gradient: shimmerGradient),
                  const SizedBox(height: 6),
                  _buildShimmerBox(width: double.infinity, height: 14, gradient: shimmerGradient),
                  const SizedBox(height: 6),
                  _buildShimmerBox(width: 150, height: 14, gradient: shimmerGradient),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
    required LinearGradient gradient,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            bounds.left - (bounds.width * _controller.value),
            bounds.top,
            bounds.width * 2,
            bounds.height,
          ),
          textDirection: Directionality.of(context),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}