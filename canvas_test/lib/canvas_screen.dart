import 'dart:math';

import 'package:flutter/material.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;
  late AnimationController _controller3;
  List<Widget> pathWidgetList = [];
  int firstClick = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // _controller.forward();
    // _controller2.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void clickButton() {
    print(firstClick);
    if (firstClick == 0) {
      // pathWidgetList.add(
      //   AnimatedBuilder(
      //     animation: _controller,
      //     builder: (context, child) {
      //       return CustomPaint(
      //         painter: DottedCurvePainter(
      //           startPoint: Offset(200, 700),
      //           endPoint: Offset(100, 400),
      //           direction: NodeDirection.left,
      //           animation: _controller,
      //         ),
      //         child: Container(
      //           width: 400,
      //           height: 800,
      //         ),
      //       );
      //     },
      //   ),
      // );
      // setState(() {
      //   _controller.forward();
      // });
      _controller.forward();
      firstClick++;
    } else if (firstClick == 1) {
      print("here!");

      // _controller.dispose();

      // _controller2 = AnimationController(
      //   duration: Duration(seconds: 1),
      //   vsync: this,
      // );

      // pathWidgetList.add(
      //   AnimatedBuilder(
      //     animation: _controller2,
      //     builder: (context, child) {
      //       return CustomPaint(
      //         painter: DottedCurvePainter(
      //           startPoint: Offset(100, 400),
      //           endPoint: Offset(250, 200),
      //           direction: NodeDirection.right,
      //           animation: _controller2,
      //         ),
      //         child: Container(
      //           width: 400,
      //           height: 800,
      //         ),
      //       );
      //     },
      //   ),
      // );
      // setState(() {
      //   print(pathWidgetList);
      //   _controller2.forward();
      // });
      _controller2.forward();
      firstClick++;
    } else if (firstClick == 2) {
      _controller3.forward();
      firstClick++;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Animated Dotted Curve Path')),
      body: SingleChildScrollView(
          child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return CustomPaint(
                painter: DottedCurvePainter(
                  startPoint: Offset(300, 400),
                  endPoint: Offset(100, 100),
                  direction: NodeDirection.left,
                  animation: _controller3,
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return CustomPaint(
                painter: DottedCurvePainter(
                  startPoint: Offset(100, 700),
                  endPoint: Offset(300, 400),
                  direction: NodeDirection.right,
                  animation: _controller2,
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: DottedCurvePainter(
                  startPoint: Offset(200, 1000),
                  endPoint: Offset(100, 700),
                  direction: NodeDirection.left,
                  animation: _controller,
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: clickButton,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

enum NodeDirection { left, right }

class DottedCurvePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final NodeDirection direction;
  final Animation<double> animation;

  DottedCurvePainter({
    required this.startPoint,
    required this.endPoint,
    required this.direction,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);

    final controlPoint1 = Offset(
      startPoint.dx + 100 * animation.value,
      startPoint.dy - 100 * animation.value,
    );

    final controlPoint2 = direction == NodeDirection.left
        ? Offset(
            endPoint.dx - 100 * animation.value,
            endPoint.dy + 100 * animation.value,
          )
        : Offset(
            endPoint.dx + 100 * animation.value,
            endPoint.dy + 100 * animation.value,
          );

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // final controlPoint3 = Offset(
    //   endPoint.dx + 100 * animationValue,
    //   endPoint.dy - 100 * animationValue,
    // );
    // final controlPoint4 = Offset(
    //   thirdPoint.dx + 100 * animationValue,
    //   thirdPoint.dy + 100 * animationValue,
    // );

    // path.cubicTo(
    //   controlPoint3.dx,
    //   controlPoint3.dy,
    //   controlPoint4.dx,
    //   controlPoint4.dy,
    //   thirdPoint.dx,
    //   thirdPoint.dy,
    // );

    final metrics = path.computeMetrics();
    final dashPath = Path();

    for (var metric in metrics) {
      final length = metric.length * animation.value;
      dashPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
