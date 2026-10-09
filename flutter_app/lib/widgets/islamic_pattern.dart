import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// پس‌زمینه الگوی هندسی اسلامی (ستاره هشت‌پر) با CustomPainter
class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final Color? color;
  const IslamicPatternBackground({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _StarPatternPainter(
              color: color ?? AppColors.gold.withOpacity(0.06),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _StarPatternPainter extends CustomPainter {
  final Color color;
  _StarPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const tile = 84.0;
    for (double y = 0; y < size.height + tile; y += tile) {
      for (double x = 0; x < size.width + tile; x += tile) {
        _drawEightStar(canvas, Offset(x, y), 26, paint);
      }
    }
  }

  void _drawEightStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i - math.pi / 2;
      final p = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    // ستاره معکوس (تسطیح برای حس هندسه اسلامی)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StarPatternPainter old) => old.color != color;
}

/// نشان آیکونیک اسلامی (گنبد + هلال) برای هدر صفحه
class IslamicEmblem extends StatelessWidget {
  final double size;
  const IslamicEmblem({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EmblemPainter(),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = AppColors.emerald;
    final gold = Paint()..color = AppColors.gold;

    // گنبد
    final dome = Path()
      ..moveTo(size.width * 0.25, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.32,
        size.width * 0.5, size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.32,
        size.width * 0.75, size.height * 0.72,
      )
      ..close();
    canvas.drawPath(dome, green);

    // پایه
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18, size.height * 0.72,
          size.width * 0.64, size.height * 0.1,
        ),
        const Radius.circular(4),
      ),
      gold,
    );

    // هلال
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.07,
      gold,
    );
    canvas.drawCircle(
      Offset(size.width * 0.53, size.height * 0.21),
      size.width * 0.07,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
