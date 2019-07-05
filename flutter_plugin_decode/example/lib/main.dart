import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_decode/flutter_plugin_decode.dart';
import 'devices_holder.dart';
import 'package:camera/camera.dart';

void  main()async{
  try{
    await availableCameras().then((cameraList){
      DevicesHolder.singleton.assembleCameraInfo(cameraList);
    });

  }on CameraException catch (e) {
    //logError(e.code, e.description);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  List<CameraDescription> cameras = DevicesHolder.singleton.cameras;
  
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String result = "未获取到结果";

  CameraController controller;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
    controller.stopImageStream();
    controller.dispose();
  }
  

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPluginDecode.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                child: Stack(
                  children: <Widget>[
                    CameraPreview(controller),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Text(result,style: TextStyle(fontSize: 20,color: Colors
                    .black),),
              ),
              
              Text('Running on: $_platformVersion\n'),
            ],
          ),
        ),
      ),
    );
  }


  bool isDetecting = false;

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
      await controller.initialize().then((_){
        if(!mounted){
          return;
        }
        setState(() {

        });

        controller.startImageStream((image){
          if(! isDetecting){
            isDetecting = true;
            FlutterPluginDecode.decodeImage(image).then((result){
              setState(() {
                this.result = result;
                isDetecting = false;
              });
            });
          }
        });

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
