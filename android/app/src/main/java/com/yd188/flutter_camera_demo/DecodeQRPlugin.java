package com.yd188.flutter_camera_demo;

import java.lang.ref.SoftReference;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

/**
 * @author aichonghui
 * @date 2019/6/24.
 */
public class DecodeQRPlugin implements MethodChannel.MethodCallHandler {

    private PluginRegistry.Registrar registrar;

    public static void registerWith(PluginRegistry.Registrar registrar){
//        if (alreadyRegisteredWith(registrar.platformViewRegistry())) {
//            return;
//        }
        final MethodChannel channel = new MethodChannel(registrar.messenger(),"decode_qr_plugin");
        channel.setMethodCallHandler(DecodeQRPlugin.getSingleton(registrar));
    }

//    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
//        final String key = DecodeQRPlugin.class.getCanonicalName();
//        if (registry.hasPlugin(key)) {
//            return true;
//        }
//        registry.registrarFor(key);
//        return false;
//    }

    private static volatile DecodeQRPlugin singleton;
    public static DecodeQRPlugin getSingleton(PluginRegistry.Registrar registrar){
        if (singleton == null){
            synchronized (DecodeQRPlugin.class){
                if (singleton == null){
                    singleton = new DecodeQRPlugin(registrar);
                }
            }
        }
        return singleton;
    }

    private DecodeQRPlugin(PluginRegistry.Registrar registrar){
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        if (methodCall.method.equals("decodeQR")){
            //
            byte[] bytesY = methodCall.argument("bytesY");
            byte[] bytesU = methodCall.argument("bytesU");
            byte[] bytesV = methodCall.argument("bytesV");

            String decodeResult = DecodeQRCodeUtil.getSingleton(registrar.context())
                    .loadUint8ListData(bytesY,bytesU,bytesV)
                    .decodeQRCodeForResult();
            result.success(decodeResult);
        }else{
            result.notImplemented();
        }

    }
}










