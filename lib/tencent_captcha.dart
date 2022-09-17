import 'dart:convert';

import 'package:flutter/services.dart';

import 'tencent_captcha_config.dart';

const _kMethodChannelName = 'flutter_tencent_captcha';
const _kEventChannelName = 'flutter_tencent_captcha/event_channel';

class TencentCaptcha {
  static const MethodChannel _methodChannel =
      MethodChannel(_kMethodChannelName);
  static const EventChannel _eventChannel = EventChannel(_kEventChannelName);

  static bool _eventChannelReadied = false;

  static String? sdkAppId;
  static Function(dynamic)? _verifyOnLoaded;
  static Function(dynamic)? _verifyOnSuccess;
  static Function(dynamic)? _verifyOnFail;

  static Future<String> get sdkVersion async {
    final String sdkVersion =
        await _methodChannel.invokeMethod('getSDKVersion');
    return sdkVersion;
  }

  static Future<bool> init(String appId) async {
    if (_eventChannelReadied != true) {
      _eventChannel.receiveBroadcastStream().listen(_handleVerifyOnEvent);
      _eventChannelReadied = true;
    }

    sdkAppId = appId;

    return true;
  }

  static Future<bool> verify({
    TencentCaptchaConfig? config,
    Function(dynamic data)? onLoaded,
    Function(dynamic data)? onSuccess,
    Function(dynamic data)? onFail,
  }) async {
    _verifyOnLoaded = onLoaded;
    _verifyOnSuccess = onSuccess;
    _verifyOnFail = onFail;

    config ??= TencentCaptchaConfig();
    config.appId ??= sdkAppId;

    return await _methodChannel.invokeMethod('verify', {
      'config': json.encode(config.toJson()),
    });
  }

  static _handleVerifyOnEvent(dynamic event) {
    String method = '${event['method']}';
    dynamic data = event['data'];

    switch (method) {
      case 'onLoaded':
        if (_verifyOnLoaded != null) _verifyOnLoaded!(data);
        break;
      case 'onSuccess':
        if (_verifyOnSuccess != null) _verifyOnSuccess!(data);
        break;
      case 'onFail':
        if (_verifyOnFail != null) _verifyOnFail!(data);
        break;
    }
  }
}
