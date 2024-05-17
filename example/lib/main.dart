import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:capture_widget/capture_widget.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _captureService = CaptureService.instance;

  CameraController? controller;
  File? _file;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  List<CameraDescription> _cameras = [];

  Future<void> initializeCamera() async {

    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      return;
    }

    final firstCamera = _cameras.isNotEmpty ? _cameras[_cameras.length > 1 ? 1 : 0] : const CameraDescription(name: 'font', lensDirection: CameraLensDirection.front, sensorOrientation: 0); // back 0th index & front 1st index
  
    controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    controller?.initialize().then((value) async {
      controller?.setFlashMode(FlashMode.off);
        setState(() {});
    } );
  }

  Future<Directory> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory;
  }

  Future<File> get _localFile async {
    final dicrect = await _localPath;
    try {
      final temp = dicrect.listSync().where((element) => element.path.split('.').last.toLowerCase() == 'png');
      print('temp 0: ${temp.length}');
      for (var p in temp) {
        p.deleteSync();
          print('delete: ${p.path}');
      }
    } catch (e){
      print("error: $e");
    }
    final temp = dicrect.listSync().where((element) => element.path.split('.').last.toLowerCase() == 'png');
    print('temp: ${temp.length}');
    return File('${dicrect.path}/temp-${DateTime.now().toString()}.png');
  }

  Future<void> takePhoto() async {
    try{
      if (_file != null && _file?.existsSync() == true) {
        setState(() {
          
          _file = null;
          
        });
        await Future.delayed(const Duration(seconds: 3));
      }

        


        final captureImage = await _captureService.captureImage();

        

        _file = await _localFile;

        

        if (captureImage == null || captureImage.isEmpty) {
          return;
        }

        await _file?.writeAsBytes(captureImage);
        
        setState(() {
          
        });
      }catch(_){
        
      }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _file != null ? Center(child: Image.file(_file!)) : Stack(
              children: [
                Positioned.fill(
                  child: CaptureWidget(
                    overRepaintKey: _captureService.globalKey,
                    child: AspectRatio(
                      aspectRatio: controller == null || controller?.value.isInitialized == false ? 1 : controller!.value.aspectRatio,
                      child: Center(child: controller == null || controller?.value.isInitialized == false ? null : CameraPreview(controller!)),
                    ),
                  ),
                ),
                
              ],
            ),
        floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.camera),
                onPressed: takePhoto,
              ),
      ),
    );
  }
}
