package com.yd188.flutter_plugin_decode;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPluginDecodePlugin */
public class FlutterPluginDecodePlugin implements MethodCallHandler {
//  /** Plugin registration. */
//  public static void registerWith(Registrar registrar) {
//    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_plugin_decode");
//    channel.setMethodCallHandler(new FlutterPluginDecodePlugin());
//  }

  private PluginRegistry.Registrar registrar;
  public static void registerWith(PluginRegistry.Registrar registrar){
    final MethodChannel channel = new MethodChannel(registrar.messenger(),"decode_qr_plugin");
    channel.setMethodCallHandler(FlutterPluginDecodePlugin.getSingleton(registrar));
  }


  private static volatile FlutterPluginDecodePlugin singleton;
  public static FlutterPluginDecodePlugin getSingleton(PluginRegistry.Registrar registrar){
    if (singleton == null){
      synchronized (FlutterPluginDecodePlugin.class){
        if (singleton == null){
          singleton = new FlutterPluginDecodePlugin(registrar);
        }
      }
    }
    return singleton;
  }

  private FlutterPluginDecodePlugin(PluginRegistry.Registrar registrar){
    this.registrar = registrar;
  }



  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("decodeQR")){

      byte[] bytesY = call.argument("bytesY");
      byte[] bytesU = call.argument("bytesU");
      byte[] bytesV = call.argument("bytesV");

      int width = (int) call.argument("width");
      int height = (int) call.argument("height");

      String decodeResult = DecodeQRCodeUtil.getSingleton(registrar.context())
              .loadUint8ListData(bytesY,bytesU,bytesV,width,height)
              .decodeQRCodeForResult();
      
      result.success(decodeResult);

    }
    else {
      result.notImplemented();
    }
  }
}
