package com.yd188.flutter_camera_demo;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    com.yd188.flutter_camera_demo.DecodeQRPlugin.registerWith(this.registrarFor("com.yd188.flutter_camera_demo.DecodeQRPlugin"));
  }
}
