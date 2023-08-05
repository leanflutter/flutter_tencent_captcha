import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tencent_captcha/flutter_tencent_captcha.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 请填写你自己的 AppId
  TencentCaptcha.init('<your appid>');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sdkVersion = 'Unknown';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String sdkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      sdkVersion = await TencentCaptcha.sdkVersion;
    } on PlatformException {
      sdkVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  void _handleClickVerify() async {
    TencentCaptchaConfig config = TencentCaptchaConfig(
      bizState: 'tencent-captcha',
      enableDarkMode: true,
    );
    await TencentCaptcha.verify(
      config: config,
      onLoaded: (dynamic data) {
        _addLog('onLoaded', data);
      },
      onSuccess: (dynamic data) {
        _addLog('onSuccess', data);
      },
      onFail: (dynamic data) {
        _addLog('onFail', data);
      },
    );
  }

  void _addLog(String method, dynamic data) {
    _logs.add('>>>$method');
    if (data != null) _logs.add(json.encode(data));
    _logs.add(' ');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Text('SDKVersion: $_sdkVersion'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('验证'),
                      onPressed: () => _handleClickVerify(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var log in _logs)
                        Text(
                          log,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
