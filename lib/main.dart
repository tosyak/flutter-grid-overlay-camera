import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:sensors/sensors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );
    _controller.setFlashMode(FlashMode.off);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {
            _handleFocus(details);
          },
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1080 / 1920,
                        child: SizedBox(child: CameraPreview(_controller)),
                      ),
                      AspectRatio(
                        aspectRatio: 1080 / 1920,
                        child: CustomPaint(
                          painter: LinePainter(),
                        ),
                      ),
                      const Positioned(
                          bottom: 15, left: 10, child: BubbleLevel())
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            await _controller.setFlashMode(FlashMode.off);

            final image = await _controller.takePicture();
            _saveImageWithGridOverlay(image);
            if (!mounted) return;
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  void _handleFocus(TapDownDetails details) async {
    try {
      final touchX = details.localPosition.dx;
      final touchY = details.localPosition.dy;
      final screenSize = MediaQuery.of(context).size;
      final focusPoint = Offset(
        touchX / screenSize.width,
        touchY / screenSize.height,
      );

      await _controller.setFocusMode(FocusMode.auto);
      await _controller.setFocusPoint(focusPoint);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveImageWithGridOverlay(imageFile) async {
    final image = await _getImageFromXFile(imageFile!);
    final size = ui.Size(image.width.toDouble(), image.height.toDouble());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());
    _drawGrid(canvas, size, 8);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final qwe = pngBytes!.buffer.asUint8List();

    await ImageGallerySaver.saveImage(Uint8List.fromList(qwe),
        quality: 100, name: 'grid_camera');

    _openImage(qwe);
  }

  void _openImage(imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.memory(imageFile),
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _getImageFromXFile(XFile file) async {
    final data = await file.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(data, completer.complete);
    return completer.future;
  }

  void _drawGrid(Canvas canvas, Size size, int gridSize) {
    final paintLines = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint redPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 2;

    final cellWidth = size.width / 16;
    final cellHeight = size.height / 32;

    for (var i = 1; i < 16; i++) {
      final x = i * cellWidth;
      final y = i * cellHeight;
      if (i == 8) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          redPaint,
        );
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintLines);
      }
    }
    for (var i = 1; i < 32; i++) {
      final x = i * cellWidth;
      final y = i * cellHeight;
      if (i == 16) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          redPaint,
        );
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLines);
      }
    }
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLines = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Paint redPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 1;

    final cellWidth = size.width / 16;
    final cellHeight = size.height / 32;

    for (var i = 1; i < 16; i++) {
      final x = i * cellWidth;
      final y = i * cellHeight;
      if (i == 8) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          redPaint,
        );
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintLines);
      }
    }
    for (var i = 1; i < 32; i++) {
      final x = i * cellWidth;
      final y = i * cellHeight;
      if (i == 16) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          redPaint,
        );
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLines);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BubbleLevel extends StatefulWidget {
  const BubbleLevel({super.key});

  @override
  _BubbleLevelState createState() => _BubbleLevelState();
}

class _BubbleLevelState extends State<BubbleLevel> {
  double _xOrientation = 0.0;
  double _zOrientation = 0.0;

  void _listenToSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _xOrientation = event.x;
        _zOrientation = event.z;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToSensors();
  }

  @override
  Widget build(BuildContext context) {
    bool isLevel = (_xOrientation > -0.5 && _xOrientation < 0.5) &&
        (_zOrientation > -0.5 && _zOrientation < 0.5);

    Container bubble = Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: isLevel ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(25.0),
      ),
    );

    SizedBox viewfinder = SizedBox(
      width: 50.0,
      height: 50.0,
      child: Center(child: bubble),
    );

    return viewfinder;
  }
}
