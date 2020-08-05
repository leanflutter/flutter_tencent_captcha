package dev.learn_flutter.plugins.flutter_tencent_captcha;

import java.io.Serializable;
import java.util.HashMap;

public class TencentCaptchaConfig implements Serializable {
    String appId;
    Object bizState;
    boolean enableDarkMode;
    HashMap<String, Object> sdkOpts;

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public Object getBizState() {
        return bizState;
    }

    public void setBizState(Object bizState) {
        this.bizState = bizState;
    }

    public boolean isEnableDarkMode() {
        return enableDarkMode;
    }

    public void setEnableDarkMode(boolean enableDarkMode) {
        this.enableDarkMode = enableDarkMode;
    }

    public HashMap<String, Object> getSdkOpts() {
        return sdkOpts;
    }

    public void setSdkOpts(HashMap<String, Object> sdkOpts) {
        this.sdkOpts = sdkOpts;
    }
}
