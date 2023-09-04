import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:canvas_test/nodeDirection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class CanvasScreen extends StatefulWidget {
  final int nodeCount;

  const CanvasScreen({super.key, required this.nodeCount});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen>
    with TickerProviderStateMixin {
  List<NodeDirection> directionList = [];
  List<AnimationController> pathControllers = [];
  List<AnimationController> cursorControllers = [];
  late AnimationController nodeAnimationController;
  late AnimationController nodeSizeAnimationController;
  List<Widget> pathWidgetList = [];
  List<Widget> nodeWidgetList = [];
  int firstClick = 0;

  @override
  void initState() {
    directionList = NodeDirectionGenerator().generate(widget.nodeCount);

    for (int i = 0; i < widget.nodeCount; i++) {
      pathControllers.add(AnimationController(
          duration: Duration(milliseconds: 400), vsync: this));
      cursorControllers.add(
          AnimationController(duration: Duration(seconds: 1), vsync: this));
      pathControllers[i].addListener(() {
        if (pathControllers[i].status == AnimationStatus.completed) {
          if (i != 0) {
            cursorControllers[i - 1].reset();
          }
          cursorControllers[i].forward();
        }
      });
    }

    nodeAnimationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    nodeSizeAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    nodeSizeAnimationController.addListener(() {
      if (nodeSizeAnimationController.status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1), () {
          nodeAnimationController.forward();
        });
      }
    });

    for (int i = widget.nodeCount - 1; i >= 0; i--) {
      pathWidgetList.add(AnimatedBuilder(
        animation: pathControllers[i],
        builder: (context, child) {
          return AnimatedBuilder(
              animation: cursorControllers[i],
              builder: ((context, child) {
                return Container(
                  height: 250,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: DottedCurvePainter(
                        direction: directionList[i],
                        animation: pathControllers[i],
                        cursorAnimation: cursorControllers[i]),
                  ),
                );
              }));
        },
      ));
    }

    for (int i = widget.nodeCount - 1; i >= 0; i--) {
      nodeWidgetList.add(AnimatedBuilder(
        animation: nodeAnimationController,
        builder: (context, child) {
          return AnimatedBuilder(
              animation: nodeSizeAnimationController,
              builder: (context, child) {
                return NodeContainer(
                    direction: directionList[i],
                    containerheight: 250,
                    animation: nodeAnimationController,
                    sizeAnimation: nodeSizeAnimationController,
                    nodeIndex: i);
              });
        },
      ));
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clickButton() {
    if (firstClick >= widget.nodeCount) {
      return;
    }

    pathControllers[firstClick].forward();
    firstClick++;
  }

  void startNodeAnimation() {
    nodeSizeAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(title: Text('Animated Dotted Curve Path')),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                  ...pathWidgetList,
                  SizedBox(
                    height: screenHeight * 0.1,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                  ...nodeWidgetList,
                  SizedBox(
                    height: screenHeight * 0.1,
                  )
                ],
              )
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: clickButton,
              child: Icon(Icons.play_arrow),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: startNodeAnimation,
              child: Icon(Icons.play_arrow),
            ),
          ],
        ));
  }
}

class DottedCurvePainter extends CustomPainter {
  final NodeDirection direction;
  final Animation<double> animation;
  final Animation<double> cursorAnimation;

  DottedCurvePainter(
      {required this.direction,
      required this.animation,
      required this.cursorAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final startPoint;
    final endPoint;

    switch (direction) {
      case NodeDirection.centerToLeft:
        startPoint = Offset(size.width * 0.5, size.height);
        endPoint = Offset(size.width * 0.25, 0);
        break;

      case NodeDirection.centerToRight:
        startPoint = Offset(size.width * 0.5, size.height);
        endPoint = Offset(size.width * 0.75, 0);
        break;

      case NodeDirection.leftToRight:
        startPoint = Offset(size.width * 0.25, size.height);
        endPoint = Offset(size.width * 0.75, 0);
        break;

      case NodeDirection.rightToLeft:
        startPoint = Offset(size.width * 0.75, size.height);
        endPoint = Offset(size.width * 0.25, 0);
        break;

      case NodeDirection.leftToCenter:
        startPoint = Offset(size.width * 0.25, size.height);
        endPoint = Offset(size.width * 0.5, 0);
        break;

      case NodeDirection.rightToCenter:
        startPoint = Offset(size.width * 0.75, size.height);
        endPoint = Offset(size.width * 0.5, 0);
        break;
    }

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);

    final controlPointCurve = size.height / 3;

    final controlPoint1;

    switch (direction) {
      case NodeDirection.rightToLeft:
        controlPoint1 = Offset(
          startPoint.dx - controlPointCurve * animation.value,
          startPoint.dy - controlPointCurve * animation.value,
        );
        break;
      case NodeDirection.rightToCenter:
        controlPoint1 = Offset(
          startPoint.dx - controlPointCurve * animation.value,
          startPoint.dy - controlPointCurve * animation.value,
        );
        break;
      default:
        controlPoint1 = Offset(
          startPoint.dx + controlPointCurve * animation.value,
          startPoint.dy - controlPointCurve * animation.value,
        );
    }

    final controlPoint2;

    switch (direction) {
      case NodeDirection.rightToLeft:
        controlPoint2 = Offset(
          endPoint.dx - controlPointCurve * animation.value,
          endPoint.dy + controlPointCurve * animation.value,
        );
        break;
      case NodeDirection.centerToLeft:
        controlPoint2 = Offset(
          endPoint.dx - controlPointCurve * animation.value,
          endPoint.dy + controlPointCurve * animation.value,
        );
        break;
      case NodeDirection.rightToCenter:
        controlPoint2 = Offset(
          endPoint.dx - controlPointCurve * animation.value,
          endPoint.dy + controlPointCurve * animation.value,
        );
        break;
      default:
        controlPoint2 = Offset(
          endPoint.dx + controlPointCurve * animation.value,
          endPoint.dy + controlPointCurve * animation.value,
        );
    }

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    final metrics = path.computeMetrics();
    final dashPath = Path();
    final dashLength = 10.0;

    for (var metric in metrics) {
      final length = metric.length * animation.value;
      dashPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(dashPath, paint);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const shadowOffset = 15;
    final shadowStartPoint;
    final shadowEndPoint;

    switch (direction) {
      case NodeDirection.centerToLeft:
      case NodeDirection.centerToRight:
        shadowStartPoint = Offset(startPoint.dx, startPoint.dy);
        shadowEndPoint = Offset(endPoint.dx - shadowOffset, endPoint.dy);
        break;

      case NodeDirection.leftToCenter:
      case NodeDirection.rightToCenter:
        shadowStartPoint = Offset(startPoint.dx - shadowOffset, startPoint.dy);
        shadowEndPoint = Offset(endPoint.dx, endPoint.dy);
        break;

      default:
        shadowStartPoint = Offset(startPoint.dx - shadowOffset, startPoint.dy);
        shadowEndPoint = Offset(endPoint.dx - shadowOffset, endPoint.dy);
    }

    final shadowPath = Path();
    shadowPath.moveTo(shadowStartPoint.dx, shadowStartPoint.dy);

    shadowPath.cubicTo(
      controlPoint1.dx - 15,
      controlPoint1.dy,
      controlPoint2.dx - 15,
      controlPoint2.dy,
      shadowEndPoint.dx,
      shadowEndPoint.dy,
    );

    final shadowMetrics = shadowPath.computeMetrics();
    final dashShadowPath = Path();

    for (var metric in shadowMetrics) {
      final length = metric.length * animation.value;
      dashShadowPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(dashShadowPath, shadowPaint);

    double animationValue = cursorAnimation.value;

    if (animationValue == 0.0) {
      return;
    }

    print("Animation value: ${animationValue}");

    final newMetrics = dashPath.computeMetrics();

    final cursorPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final circleRadius = 12.0;
    final arrowSize = 12;

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var metric in newMetrics) {
      ui.Tangent tangent =
          metric.getTangentForOffset(animationValue * metric.length)!;
      Offset cursorPosition = tangent.position;

      canvas.drawCircle(cursorPosition, circleRadius, cursorPaint);
      final arrowDirection = atan2(tangent.vector.dy, tangent.vector.dx);

      final arrowPosition = Offset(
        cursorPosition.dx,
        cursorPosition.dy,
      );

      final arrowPath = Path()
        ..moveTo(arrowPosition.dx + arrowSize / 2 * cos(arrowDirection),
            arrowPosition.dy + arrowSize / 2 * sin(arrowDirection))
        ..lineTo(
            arrowPosition.dx + arrowSize / 2 * cos(arrowDirection + pi / 2),
            arrowPosition.dy + arrowSize / 2 * sin(arrowDirection + pi / 2))
        ..lineTo(
            arrowPosition.dx + arrowSize / 2 * cos(arrowDirection - pi / 2),
            arrowPosition.dy + arrowSize / 2 * sin(arrowDirection - pi / 2))
        ..close();

      canvas.save();

      canvas.drawPath(arrowPath, arrowPaint);

      canvas.restore();

      // break;
    }

    final newShadowMetrics = dashShadowPath.computeMetrics();

    final cursorShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var metric in newShadowMetrics) {
      ui.Tangent tangent =
          metric.getTangentForOffset(animationValue * metric.length)!;
      Offset cursorShadowPosition = tangent.position;

      canvas.drawCircle(cursorShadowPosition, circleRadius, cursorShadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class NodeContainer extends StatefulWidget {
  final NodeDirection direction;
  final double containerheight;
  final Animation<double> animation;
  final Animation<double> sizeAnimation;
  final int nodeIndex;

  const NodeContainer(
      {super.key,
      required this.direction,
      required this.containerheight,
      required this.animation,
      required this.sizeAnimation,
      required this.nodeIndex});

  @override
  State<NodeContainer> createState() => _NodeContainerState();
}

class _NodeContainerState extends State<NodeContainer> {
  double calculateOffsetX(double screenWidth) {
    double x;
    final xAxisOffset = screenWidth * 0.15;

    switch (widget.direction) {
      case NodeDirection.centerToLeft:
      case NodeDirection.rightToLeft:
        x = screenWidth * 0.25 + xAxisOffset * (1 - widget.animation.value);
        break;

      case NodeDirection.centerToRight:
      case NodeDirection.leftToRight:
        x = screenWidth * 0.75 - xAxisOffset * (1 - widget.animation.value);
        break;

      case NodeDirection.rightToCenter:
        x = screenWidth * 0.5 + xAxisOffset * (1 - widget.animation.value);
        break;

      case NodeDirection.leftToCenter:
        x = screenWidth * 0.5 - xAxisOffset * (1 - widget.animation.value);
        break;

      default:
        x = screenWidth * 0.5;
    }

    return x;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: widget.containerheight,
      width: screenWidth,
      child: Stack(children: [
        Transform.translate(
            offset: Offset(
                calculateOffsetX(screenWidth) - 10,
                (widget.nodeIndex + 1) *
                        (150 / 2) *
                        (1 - widget.animation.value) -
                    10),
            child: Stack(
              children: [
                // SvgPicture.asset(
                //   'assets/journey_node_inner_shadow.svg',
                //   width: 50,
                //   height: 50,
                //   // colorFilter: ColorFilter.mode(Colors.blue, BlendMode.color),
                // )
                CircleAvatar(
                  radius: 10 * widget.sizeAnimation.value,
                  backgroundColor: Colors.blue,
                )
              ],
            ))
      ]),
    );
  }
}
