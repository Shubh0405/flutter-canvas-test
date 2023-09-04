import 'package:flutter/material.dart';

class CurvedLineAnimation extends StatefulWidget {
  @override
  _CurvedLineAnimationState createState() => _CurvedLineAnimationState();
}

class _CurvedLineAnimationState extends State<CurvedLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 0.4 * MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CustomPaint(
            painter: CurvedLinePainter(_animation),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CurvedLinePainter extends CustomPainter {
  final Animation<double> animation;

  CurvedLinePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(size.width / 2, size.height);
    final endPoint =
        Offset(size.width / 2, size.height * (1 - animation.value));

    final controlPoint1 = Offset(startPoint.dx, size.height * 0.75);
    final controlPoint2 =
        Offset(startPoint.dx, size.height * (1 - animation.value));

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, endPoint.dx, endPoint.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
