import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:capture_widget/capture_widget.dart';

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
  Image? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: image != null ? Center(child: image) : SingleChildScrollView(
          child: CaptureWidget(overRepaintKey: _captureService.globalKey, child: Column(
              children: List.generate(
                30,
                (i) => Container(
                      color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                      height: 100,
                    ),
              ),
            ),
          ),
        ),
        floatingActionButton: image == null
            ? FloatingActionButton(
                child: const Icon(Icons.camera),
                onPressed: () async {
                  final captureImage = await _captureService.captureImage();
                  if (captureImage == null) return;
                  setState(() => image = Image.memory(captureImage));
                },
              )
            : FloatingActionButton(
                onPressed: () => setState(() => image = null),
                child: const Icon(Icons.remove),
              ),
      ),
    );
  }
}
