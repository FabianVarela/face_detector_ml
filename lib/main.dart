import 'package:face_detector_ml/detector_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetectorPage(title: "Demo - Face recognition"),
      title: "Demo - Face recognition",
    );
  }
}
