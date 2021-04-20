package org.leanflutter.plugins.flutter_tencent_captcha;

import android.app.Activity;
import android.app.ActivityOptions;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterTencentCaptchaPlugin
 */
public class FlutterTencentCaptchaPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
    private static final String CHANNEL_NAME = "flutter_tencent_captcha";
    private static final String EVENT_CHANNEL_NAME = "flutter_tencent_captcha/event_channel";

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private Context context;
    private Activity activity;

    private String captchaHtmlPath;
    private String appId;

    private void setupChannel(BinaryMessenger messenger, Context context) {
        this.context = context;

        this.channel = new MethodChannel(messenger, CHANNEL_NAME);
        this.channel.setMethodCallHandler(this);

        this.eventChannel = new EventChannel(messenger, EVENT_CHANNEL_NAME);
        this.eventChannel.setStreamHandler(this);
    }

    private void teardownChannel() {
        this.context = null;

        this.channel.setMethodCallHandler(null);
        this.channel = null;

        this.eventChannel.setStreamHandler(null);
        this.eventChannel = null;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.captchaHtmlPath = flutterPluginBinding.getFlutterAssets().getAssetFilePathBySubpath("assets/captcha.html", "flutter_tencent_captcha");
        this.setupChannel(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        this.teardownChannel();
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    @Override
    public void onListen(Object args, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object args) {
        this.eventSink = null;
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        FlutterTencentCaptchaPlugin plugin = new FlutterTencentCaptchaPlugin();
        plugin.setupChannel(registrar.messenger(), registrar.activeContext());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getSDKVersion")) {
            handleMethodGetSDKVersion(call, result);
        } else if (call.method.equals("init")) {
            handleMethodInit(call, result);
        } else if (call.method.equals("verify")) {
            handleMethodVerify(call, result);
        } else {
            result.notImplemented();
        }
    }


    private void handleMethodGetSDKVersion(@NonNull MethodCall call, @NonNull Result result) {
        result.success("0.0.1");
    }

    private void handleMethodInit(@NonNull MethodCall call, @NonNull Result result) {
        this.appId = call.argument("appId");
        result.success(true);
    }

    private void handleMethodVerify(@NonNull MethodCall call, @NonNull final Result result) {
        String configJsonString = "{}";

        if (call.hasArgument("config"))
            configJsonString = call.argument("config");

        TencentCaptchaSender.getInstance().listene(new TencentCaptchaListener() {
            @Override
            public void onLoaded(String data) {
                final Map<String, Object> result = new HashMap<>();
                result.put("method", "onLoaded");
                result.put("data", convertMsgToMap(data));

                eventSink.success(result);
            }

            @Override
            public void onSuccess(String data) {
                final Map<String, Object> result = new HashMap<>();
                result.put("method", "onSuccess");
                result.put("data", convertMsgToMap(data));

                eventSink.success(result);
            }

            @Override
            public void onFail(String msg) {
                final Map<String, Object> result = new HashMap<>();
                result.put("method", "onFail");
                result.put("data", convertMsgToMap(msg));

                eventSink.success(result);
            }
        });

        Intent intent = new Intent(activity, TencentCaptchaActivity.class);
        intent.putExtra("captchaHtmlPath", this.captchaHtmlPath);
        intent.putExtra("configJsonString", configJsonString);
        activity.startActivity(intent);
        activity.overridePendingTransition(0, 0);

        result.success(true);
    }

    private static Map<String, Object> convertMsgToMap(String jsonString) {
        Map<String, Object> map = new HashMap<String, Object>();
        JSONObject jsonObject = null;
        try {
            jsonObject = new JSONObject(jsonString);
            map = toMap(jsonObject);
        } catch (JSONException ex) {
            // skip;
        }
        return map;
    }

    private static Map<String, Object> toMap(JSONObject jsonObject) throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            Object value = jsonObject.get(key);
            if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }
        return map;
    }
}
