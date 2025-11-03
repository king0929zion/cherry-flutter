import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// SquircleImage - 圆角平滑矩形图片
/// 使用 CustomPainter 实现类似 FastSquircleView 的效果
class SquircleImage extends StatelessWidget {
  final ImageProvider image;
  final double width;
  final double height;
  final double borderRadius;
  final double cornerSmoothing;

  const SquircleImage({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.borderRadius = 20,
    this.cornerSmoothing = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SquirclePainter(
        image: image,
        borderRadius: borderRadius,
        cornerSmoothing: cornerSmoothing,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Image(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _SquirclePainter extends CustomPainter {
  final ImageProvider image;
  final double borderRadius;
  final double cornerSmoothing;

  _SquirclePainter({
    required this.image,
    required this.borderRadius,
    required this.cornerSmoothing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 简化实现：使用圆角矩形路径
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );
    canvas.clipPath(path);
  }

  @override
  bool shouldRepaint(_SquirclePainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerSmoothing != cornerSmoothing;
  }
}

