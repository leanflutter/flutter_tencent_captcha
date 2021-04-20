class TencentCaptchaConfig {
  String? appId;
  // 自定义透传参数，业务可用该字段传递少量数据，该字段的内容会被带入callback回调的对象中
  dynamic? bizState;
  // 开启自适应深夜模式
  bool? enableDarkMode;
  // 示例 {"width": 140, "height": 140}
  // 移动端原生webview调用时传入，为设置的验证码弹框大小。
  Map<String, dynamic>? sdkOpts;

  TencentCaptchaConfig({
    this.appId,
    this.bizState,
    this.enableDarkMode,
    this.sdkOpts,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = Map<String, dynamic>();
    if (appId != null) jsonObject.putIfAbsent("appId", () => appId);
    if (bizState != null) jsonObject.putIfAbsent("bizState", () => bizState);
    if (enableDarkMode != null)
      jsonObject.putIfAbsent("enableDarkMode", () => enableDarkMode);
    if (sdkOpts != null) jsonObject.putIfAbsent("sdkOpts", () => sdkOpts);

    return jsonObject;
  }
}
