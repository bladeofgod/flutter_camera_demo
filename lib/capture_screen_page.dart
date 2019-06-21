import 'package:flutter/material.dart';
import 'devices_holder.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class CaptureScreenPage extends StatefulWidget {
  List<CameraDescription> cameras = DevicesHolder.singleton.cameras;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CaptureScreenPageState();
  }
}

class CaptureScreenPageState extends State<CaptureScreenPage> {
  CameraController controller;

  bool recycleIn = true;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    recycleIn = false;
    controller.dispose();
  }

  GlobalKey _repaintBoundary = GlobalKey();
  List<Uint8List>  bytes = new List();

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
//            Image.network(
//              "http://qiniu.nightfarmer.top/test.gif",
//              width: 300,
//              height: 300,
//            ),
          RepaintBoundary(
          key: _repaintBoundary,
          child:Container(
            height: 300,
            child: CameraPreview(controller),
          ),
        ),

          FlatButton(
            onPressed: () {
              this._capturePng();
            },
            child: Text("全屏截图"),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Image.memory(
                  bytes[index],
                  fit: BoxFit.cover,
                );
              },
              itemCount: bytes.length,
              scrollDirection: Axis.horizontal,
            ),
          )
        ],
      ),
    );


//    return Container(
//      child: Column(
//        children: <Widget>[
//        RepaintBoundary(
//        key: _repaintBoundary,
//        child:Container(
//          height: 300,
//          child: CameraPreview(controller),
//        ),),
//          Container(
//            child: FlatButton(
//              onPressed: () {
//                this._capturePng();
//              },
//              child: Text("全屏截图"),
//            ),
//          ),
//          Container(
//            height: 300,
//            child: ListView.builder(
//              itemBuilder: (context, index) {
//                return Image.memory(
//                  bytes[index],
//                  fit: BoxFit.cover,
//                );
//              },
//              itemCount: bytes.length,
//              scrollDirection: Axis.vertical,
//            ),
//          ),
//        ],
//      ),
//    );


  }

  _startCapturePng() {
//    if (recycleIn) {
//      Future.delayed(Duration(seconds: 1), () {
//        _capturePng();
//      });
//    }
  }

  _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintBoundary.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      bytes.add(pngBytes);
      setState(() {});
      _startCapturePng();
      return pngBytes;
    } catch (e) {
      print(e);
    }

    return null;
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    //if (controller != null) await controller.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.low);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        _startCapturePng();
      });
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  void showException(CameraException e) {
    logError(e.code, e.description);
    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');
}
