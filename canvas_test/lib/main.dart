import 'package:canvas_test/canvas_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas test',
      debugShowCheckedModeBanner: false,
      home: const CanvasScreen(),
    );
  }
}
