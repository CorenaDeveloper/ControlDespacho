import 'package:flutter/material.dart';
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width - strokeWidth) / 2;
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (2 * gap)).floor();
    final dashWidth = (circumference - (dashCount * gap)) / dashCount;

    double startAngle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
      startAngle += (dashWidth + gap) / radius;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
class DashedCircleContainer extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final double gap;
  final Widget child;

  const DashedCircleContainer({
    super.key,
    required this.size,
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DashedCirclePainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
      ),
      child: Center(
        child: Container(
          width: size - strokeWidth * 2,
          height: size - strokeWidth * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: child
          ),
        ),
      ),
    );
  }
}
