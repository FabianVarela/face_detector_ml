import 'dart:io';

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
  List<Face> _faces;

  void _pickImage() async {
    setState(() {
      _imageFile = null;
    });

    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    dynamic faces;

    if (imageFile != null) {
      final image = FirebaseVisionImage.fromFile(imageFile);
      final faceDetector = FirebaseVision.instance.faceDetector();
      faces = await faceDetector.processImage(image);
    }

    setState(() {
      if (mounted) {
        _imageFile = imageFile;
        _faces = faces;
      }
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
  ImageAndFaces({this.imageFile, this.faces});

  final File imageFile;
  final List<Face> faces;

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
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text("(${pos.top}, ${pos.left}), (${pos.bottom}, ${pos.right})"),
    );
  }
}
