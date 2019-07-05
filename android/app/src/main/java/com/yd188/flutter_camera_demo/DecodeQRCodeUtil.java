package com.yd188.flutter_camera_demo;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.YuvImage;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicYuvToRGB;
import android.renderscript.Type;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

/**
 * @author aichonghui
 * @date 2019/6/24.
 */
public class DecodeQRCodeUtil {

    private static SoftReference<Context> contextSoftReference;

    private static volatile DecodeQRCodeUtil singleton;

    public static DecodeQRCodeUtil getSingleton(Context context){
        if (singleton == null){
            synchronized (DecodeQRCodeUtil.class){
                if (singleton == null){
                    singleton = new DecodeQRCodeUtil();
                }
            }
        }
        contextSoftReference = new SoftReference<>(context);
        return singleton;
    }

    private byte[] y;
    private byte[] u;
    private byte[] v;

    public DecodeQRCodeUtil loadUint8ListData(byte[] y ,byte[] u, byte[] v){
        this.y = y;
        this.u = u;
        this.v = v;

        return this;
    }

    public String decodeQRCodeForResult(){

        Map<DecodeHintType,String> hints = new HashMap<DecodeHintType,String>();
        hints.put(DecodeHintType.CHARACTER_SET,"utf-8");

        Bitmap bitmapRaw = convertByteArray2Bitmap();

        RGBLuminanceSource source=  new RGBLuminanceSource(bitmapRaw);
        BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
        QRCodeReader reader = new QRCodeReader();
        Result result;

        try {
            result =reader.decode(binaryBitmap,hints);

            return result.getText();

        } catch (FormatException e) {
            e.printStackTrace();
        } catch (ChecksumException e) {
            e.printStackTrace();
        } catch (NotFoundException e) {
            e.printStackTrace();
        }

        return "";

    }

    private Bitmap convertByteArray2Bitmap(){
        ByteBuffer yBuffer = ByteBuffer.wrap(y);
        ByteBuffer uBuffer = ByteBuffer.wrap(u);
        ByteBuffer vBuffer = ByteBuffer.wrap(v);

        int yb = yBuffer.remaining();
        int ub = uBuffer.remaining();
        int vb = vBuffer.remaining();

        byte[] data = new byte[yb + ub + vb];
        yBuffer.get(data,0,yb);
        vBuffer.get(data,yb,vb);
        uBuffer.get(data,yb+vb,ub);
        //YuvImage yuvImage = new YuvImage();
        Bitmap bitmapRaw = Bitmap.createBitmap(540,960, Bitmap.Config.ARGB_8888);
        Allocation bmData = renderScriptNV21ToRGBA888(
                contextSoftReference.get(),
                540,960,data
        );

        bmData.copyTo(bitmapRaw);
        return bitmapRaw;
    }

    private Allocation renderScriptNV21ToRGBA888(Context context,int width,int height,byte[] nv21){
        RenderScript renderScript = RenderScript.create(context);
        ScriptIntrinsicYuvToRGB yuvToRGB = ScriptIntrinsicYuvToRGB.create(renderScript, Element.U8_4(renderScript));
        Type.Builder yuvType = new Type.Builder(renderScript,Element.U8(renderScript)).setX(nv21.length);
        Allocation in = Allocation.createTyped(renderScript,yuvType.create(),Allocation.USAGE_SCRIPT);

        Type.Builder rgbaType = new Type.Builder(renderScript, Element.RGBA_8888(renderScript)).setX(width).setY(height);
        Allocation out = Allocation.createTyped(renderScript, rgbaType.create(), Allocation.USAGE_SCRIPT);

        in.copyFrom(nv21);

        yuvToRGB.setInput(in);
        yuvToRGB.forEach(out);

        return out;

    }

}








