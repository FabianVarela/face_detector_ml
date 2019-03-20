import 'dart:io';

import 'package:face_detector_ml/detector_painter.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class ImageAndFaces extends StatelessWidget {
  ImageAndFaces({this.imageFile, this.imageSize, this.faces});

  final File imageFile;
  final Size imageSize;
  final List<Face> faces;

  CustomPaint _buildResults(Size imageSize, List<Face> faces) {
    CustomPainter painter = DetectorPainter(imageSize, faces);

    return CustomPaint(
      painter: painter,
    );
  }

  List<Widget> validateData() {
    var list = List<Widget>();
    list.add(
      Center(
        child: Text(
          "Processing data...",
          style: TextStyle(
            color: Colors.green,
            fontSize: 30.0,
          ),
        ),
      ),
    );

    return faces == null
        ? list
        : faces.map<Widget>((f) => FaceCoordinates(f)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.file(imageFile).image,
                fit: BoxFit.fill,
              ),
            ),
            child: imageSize == null || faces == null
                ? Center(
                    child: Text(
                      "Scanning...",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 30.0,
                      ),
                    ),
                  )
                : _buildResults(imageSize, faces),
          ),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: validateData(),
          ),
        ),
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  Widget setProbability(double probability) {
    var color;
    var text;

    if (probability == null) {
      color = Colors.grey;
      text = "The face could not be processed";
    } else if (probability >= 0.0 && probability <= 0.3) {
      color = Colors.redAccent;
      text = "The person is not happy";
    } else if (probability > 0.3 && probability <= 0.7) {
      color = Colors.orangeAccent;
      text = "The person is a little happy";
    } else {
      color = Colors.lightGreen;
      text = "The person is happy";
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);

    print("=========================");
    print("Head Y: ${face.headEulerAngleY}");
    print("Head Z: ${face.headEulerAngleZ}");

    if (leftEar != null) print("LeftEar: ${leftEar.position}");

    print("Left eye: ${face.leftEyeOpenProbability}");
    print("Right eye: ${face.rightEyeOpenProbability}");

    print("Probability: ${face.smilingProbability}");
    print("Tracking: ${face.trackingId}");
    print("=========================");

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: Center(
        child: ListTile(
          title: Text(
            "Tracking Id: ${face.trackingId}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          subtitle: setProbability(face.smilingProbability),
        ),
      ),
    );
  }
}
