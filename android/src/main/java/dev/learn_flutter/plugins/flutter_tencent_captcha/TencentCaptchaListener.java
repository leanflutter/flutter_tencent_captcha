package dev.learn_flutter.plugins.flutter_tencent_captcha;

public interface TencentCaptchaListener {
    void onLoaded(String data);

    void onSuccess(String data);

    void onFail(String data);
}
