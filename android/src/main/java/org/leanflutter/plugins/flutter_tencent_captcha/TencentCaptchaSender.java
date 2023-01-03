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
        if (this.listener == null) return;
        this.listener.onLoaded(data);
    }

    void onSuccess(String data) {
        if (this.listener == null) return;
        this.listener.onSuccess(data);
    }

    void onFail(String data) {
        if (this.listener == null) return;
        this.listener.onFail(data);
    }
}
