import 'dart:async';
import 'dart:io';

import 'package:face_detector_ml/painter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: "Demo - Face recognition"),
      title: 'Face recognition',
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _imageFile;
  Size _imageSize;
  List<Face> _faces;

  void _pickImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    dynamic faces;

    if (imageFile != null) {
      final image = FirebaseVisionImage.fromFile(imageFile);
      final faceDetector = FirebaseVision.instance.faceDetector(
          FaceDetectorOptions(
              mode: FaceDetectorMode.accurate, enableLandmarks: true));
      faces = await faceDetector.processImage(image);
    }

    setState(() {
      if (mounted) {
        _getImageSize(imageFile);

        _imageFile = imageFile;
        _faces = faces;
      }
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );

    final Size imageSize = await completer.future;

    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _imageFile == null
          ? Center(child: Text('No image selected.'))
          : ImageAndFaces(
              imageFile: _imageFile,
              imageSize: _imageSize,
              faces: _faces,
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: _pickImage,
        tooltip: "Pick an image",
      ),
    );
  }
}

class ImageAndFaces extends StatelessWidget {
  ImageAndFaces({this.imageFile, this.imageSize, this.faces});

  final File imageFile;
  final Size imageSize;
  final List<Face> faces;

  CustomPaint _buildResults(Size imageSize, List<Face> faces) {
    CustomPainter painter = FaceDetectorPainter(imageSize, faces);

    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
          ),
        ),
        Flexible(
          flex: 1,
          child: imageSize == null || faces == null
              ? const Center(
                  child: Text(
                    'Scanning...',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30.0,
                    ),
                  ),
                )
              : _buildResults(imageSize, faces),
        )
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  @override
  Widget build(BuildContext context) {
    final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);

    print("Head Y: ${face.headEulerAngleY}");
    print("Head Z: ${face.headEulerAngleZ}");

    if (leftEar != null) print("LeftEar: ${leftEar.position}");

    print("Probability: ${face.smilingProbability}");
    print("Tracking: ${face.trackingId}");

    final pos = face.boundingBox;
    return ListTile(
      title: Text("(${pos.top}, ${pos.left}), (${pos.bottom}, ${pos.right})"),
      subtitle: Text("Probabilidad de felicidad: ${face.smilingProbability}"),
    );
  }
}
