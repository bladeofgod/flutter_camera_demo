import 'package:flutter/material.dart';
import 'dart:async';

import 'flutter_plugin_decode.dart';
import 'package:flutter/services.dart';
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


class MyApp extends StatefulWidget{

  List<CameraDescription> cameras = DevicesHolder.singleton.cameras;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }

}

class MyAppState extends State<MyApp> {

  String result = "未获取到结果";

  CameraController controller;

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
    controller.stopImageStream();
    controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
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
















