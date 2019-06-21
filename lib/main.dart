import 'package:flutter/material.dart';
import 'devices_holder.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'capture_screen_page.dart';


/*
* 2019.6.21
*
* 此demo 本意是获得相机图片数据后，传入给原生二维码解码
*
* Lab1 ：  所考虑的解决方法是，通过camera controller 的 iamge stream 获取cameraImage
*
* camera image 内部 有planes . byte  为 unit8list 型数据， (总共含有三组)
*
* 获得该数据后，总是无法解析成图片，所以暂时搁置 该计划
*
* 更换为另外一种方法，在camerapreview 外层包裹RenderRepaintBoundary 之后按照 一定时间延迟，
* 进行截图，传输给原生进行解码
*
*
*
*
*
* */


void main() async{
  try{
    await availableCameras().then((cameraList){
      DevicesHolder.singleton.assembleCameraInfo(cameraList);
    });

  }on CameraException catch (e) {
    //logError(e.code, e.description);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
      //lab 1 方案，搁置
      //MyHomePage(title: 'Flutter Demo Home Page')
      //lab 2 方案  截图传送
      CaptureScreenPage()
      ,
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  List<CameraDescription> cameras = DevicesHolder.singleton.cameras;

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CameraController controller;

  Uint8List bytes ;




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

    return Container(
      child: Column(
        children: <Widget>[
//          AspectRatio(
//            aspectRatio: controller.value.aspectRatio,
//            child: Container(
//              height: 300,
//              child: Stack(
//                children: <Widget>[
//                  CameraPreview(controller),
//                ],
//              ),
//            ),),
          Container(
            height: 400,
            child: Stack(
              children: <Widget>[
                CameraPreview(controller),
              ],
            ),
          ),

          Container(
            height: 300,
            color: Colors.white,
            child: bytes == null ? Icon(Icons.adb,size: 100,color: Colors.green,
            ) : Image.memory
              (bytes,
              fit:
              BoxFit
                  .cover,),
          ),
        ],
      ),
    );
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
      await controller.initialize().then((_){
        if(!mounted){
          return;
        }
        setState(() {

        });
        controller.startImageStream((CameraImage image){
          //TODO image data
          //https://www.jianshu.com/p/580ccd25d4ca
          //android image format : YUV
          print("planes 长度 ： ${image.planes.length}");
//          Plane y = image.planes[0];
//          Plane u = image.planes[1];
//          Plane v = image.planes[2];
//          List<int> uni8 = new List();
//          y.bytes.forEach((int item){
//            uni8.add(item);
//          });
//          u.bytes.forEach((item){
//            uni8.add(item);
//          });
//          v.bytes.forEach((item){
//            uni8.add(item);
//          });
//          uni8.addAll(y.bytes.toList());
//          uni8.addAll(u.bytes.toList());
//          uni8.addAll(v.bytes.toList());
          setState(() {
            bytes =Uint8List.fromList(
                image.planes.map((plane){
                  return plane.bytes;
                }).toList()
            ) ;

          });

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
