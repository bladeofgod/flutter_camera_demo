import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class FlutterPluginDecode {
  static const MethodChannel _channel =
      const MethodChannel('decode_qr_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  
  static Future<String> decodeImage(CameraImage image) async{
    return await _channel.invokeMethod("decodeQR",
        {"bytesY":image.planes[0].bytes,
          "bytesU" : image.planes[1].bytes,
          "bytesV" : image.planes[2].bytes,
          "width" : image.width,
          "height" : image.height});
  }
}
