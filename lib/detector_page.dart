import 'dart:async';
import 'dart:io';

import 'package:face_detector_ml/image_faces.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class DetectorPage extends StatefulWidget {
  DetectorPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DetectorPageState createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> {
  File _imageFile;
  Size _imageSize;
  List<Face> _faces;

  void _pickImage(bool isGallery) async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    var imageFile;

    if (isGallery) {
      imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else {
      imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    }

    if (imageFile != null) {
      _getImageSize(imageFile);
      _processImage(imageFile);
    }

    setState(() {
      if (mounted) {
        _imageFile = imageFile;
      }
    });
  }

  void _processImage(File imageFile) async {
    setState(() {
      _faces = null;
    });

    dynamic result;
    final image = FirebaseVisionImage.fromFile(imageFile);

    final faceDetector = FirebaseVision.instance.faceDetector(
        FaceDetectorOptions(
            mode: FaceDetectorMode.accurate,
            enableLandmarks: true,
            enableTracking: true,
            minFaceSize: 0.1,
            enableClassification: true));

    result = await faceDetector.processImage(image);

    setState(() {
      _faces = result;
    });
  }

  void _selectOption(BuildContext context, String value) {
    var alert = AlertDialog(
      title: Text(widget.title),
      content: Text(value),
      actions: _getDialogButtons(),
    );

    var alertIOS = CupertinoAlertDialog(
      title: Text(widget.title),
      content: Text(value),
      actions: _getDialogButtons(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Platform.isAndroid ? alert : alertIOS;
      },
    );
  }

  List<Widget> _getDialogButtons() {
    List<Widget> buttons = List();
    buttons.add(FlatButton(
      onPressed: () {
        _pickImage(false);
        Navigator.pop(context);
      },
      child: Text("From a camera"),
    ));
    buttons.add(FlatButton(
      onPressed: () {
        _pickImage(true);
        Navigator.pop(context);
      },
      child: Text("From the gallery"),
    ));

    return buttons;
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
        onPressed: () {
          _selectOption(context, "Select an option!!!");
        },
        tooltip: "Pick an image",
      ),
    );
  }
}
