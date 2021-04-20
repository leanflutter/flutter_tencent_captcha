package org.leanflutter.plugins.flutter_tencent_captcha;

public class TencentCaptchaSender {
    private static TencentCaptchaSender instance = new TencentCaptchaSender();

    public static TencentCaptchaSender getInstance() {
        return instance;
    }

    TencentCaptchaListener listener;

    void listene(TencentCaptchaListener listener) {
        this.listener = listener;
    }

    void onLoaded(String data) {
        this.listener.onLoaded(data);
    }

    void onSuccess(String data) {
        this.listener.onSuccess(data);
    }

    void onFail(String data) {
        this.listener.onFail(data);
    }
}
