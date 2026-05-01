import 'package:flutter/material.dart';
import 'dart:math' as math;

class BlobBackground extends StatefulWidget {
  final Widget child;
  const BlobBackground({super.key, required this.child});

  @override
  State<BlobBackground> createState() => _BlobBackgroundState();
}

class _BlobBackgroundState extends State<BlobBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              return CustomPaint(
                painter: BlobPainter(_anim.value),
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  final double t;
  BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0066FF).withOpacity(0.4),
          const Color(0xFF003399).withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.1 + math.sin(t * math.pi) * 30,
          size.height * 0.2 + math.cos(t * math.pi) * 20,
        ),
        radius: size.width * 0.6,
      ));

    canvas.drawCircle(
      Offset(
        size.width * 0.1 + math.sin(t * math.pi) * 30,
        size.height * 0.2 + math.cos(t * math.pi) * 20,
      ),
      size.width * 0.6,
      paintBlue,
    );

    final paintPurple = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B00FF).withOpacity(0.35),
          const Color(0xFFFF006E).withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.9 + math.cos(t * math.pi) * 20,
          size.height * 0.3 + math.sin(t * math.pi) * 30,
        ),
        radius: size.width * 0.6,
      ));

    canvas.drawCircle(
      Offset(
        size.width * 0.9 + math.cos(t * math.pi) * 20,
        size.height * 0.3 + math.sin(t * math.pi) * 30,
      ),
      size.width * 0.6,
      paintPurple,
    );

    final paintPink = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF006E).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.5,
          size.height * 0.85 + math.sin(t * math.pi * 2) * 15,
        ),
        radius: size.width * 0.5,
      ));

    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        size.height * 0.85 + math.sin(t * math.pi * 2) * 15,
      ),
      size.width * 0.5,
      paintPink,
    );
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) => oldDelegate.t != t;
}
