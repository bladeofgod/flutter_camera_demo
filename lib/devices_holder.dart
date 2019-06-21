
/*
* 对于一些设备信息的持有，保持全局共享
* 目前仅服务于 相机
*
*
* 后续看情况改进
* jiaqi -- 2019.6.17
* */


import 'package:camera/camera.dart';

class DevicesHolder {

  DevicesHolder._internal();
  static DevicesHolder singleton = DevicesHolder._internal();

  //持有设备相机的信息
  List<CameraDescription> cameras;

  assembleCameraInfo(List<CameraDescription> cameras){
    this.cameras = cameras;
  }

}