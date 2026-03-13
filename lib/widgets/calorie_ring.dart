import 'package:flutter/material.dart';
import 'dart:math';

class CalorieRing extends StatelessWidget {
  final double percent;
  final String label;
  final String sublabel;
  final double size;

  const CalorieRing({
    super.key,
    required this.percent,
    required this.label,
    required this.sublabel,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(percent: percent),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(sublabel, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final paint = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(center, radius, paint);
    final progressPaint = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * (percent / 100),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}