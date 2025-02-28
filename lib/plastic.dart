import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class PlasticDetectionPage extends StatefulWidget {
  @override
  _PlasticDetectionPageState createState() => _PlasticDetectionPageState();
}

class _PlasticDetectionPageState extends State<PlasticDetectionPage> {
  CameraController? _cameraController;
  bool isPlasticDetected = false;
  String detectedLabel = "";
  int plasticCount = 0;
  Interpreter? _interpreter;
  List<int>? modelInputShape;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadModel();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
      startImageStream();
    }
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      modelInputShape = _interpreter!.getInputTensor(0).shape;
      print("Model Loaded Successfully. Input Shape: $modelInputShape");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  void startImageStream() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (!mounted) return;
      await runModelOnFrame(image);
    });
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    if (_interpreter == null || modelInputShape == null) return;

    int inputHeight = modelInputShape![1];
    int inputWidth = modelInputShape![2];

    // Convert CameraImage to Image and resize
    img.Image convertedImage = convertYUV420ToImage(image);
    img.Image resizedImage = img.copyResize(convertedImage, width: inputWidth, height: inputHeight);

    // Convert to Float32List (normalize pixels 0-1)
    Uint8List inputBytes = resizedImage.getBytes();
    Float32List input = Float32List.fromList(inputBytes.map((e) => e / 255.0).toList());

    // Prepare Output
    var output = List.filled(1, 0).reshape([1, 1]);

    // Run Model
    _interpreter!.run(input, output);

    print("Model Output: $output");

    int detectedClass = output[0][0];
    if (detectedClass == 1 && !isPlasticDetected) {
      setState(() {
        isPlasticDetected = true;
        detectedLabel = "Plastic Detected";
      });
      updatePlasticCount();
    } else {
      setState(() {
        isPlasticDetected = false;
        detectedLabel = "";
      });
    }
  }

  img.Image convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final yRowStride = image.planes[0].bytesPerRow;

    img.Image imgBuffer = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.planes[0].bytes[y * yRowStride + x];
        imgBuffer.setPixelRgb(x, y, pixel, pixel, pixel);
      }
    }

    return imgBuffer;
  }

  Future<void> updatePlasticCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('students').doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);
      if (!snapshot.exists) return;
      int currentCount = (snapshot["plastic_count"] ?? 0) as int;
      transaction.update(userDoc, {"plastic_count": currentCount + 1});
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: isPlasticDetected ? Colors.green : Colors.red, width: 4),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                detectedLabel,
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
