package dev.learn_flutter.plugins.flutter_tencent_captcha;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

class TencentCaptchaJsInterface {
    private Handler handler = new Handler(Looper.getMainLooper());
    private DialogInterface.OnDismissListener listener;

    public TencentCaptchaJsInterface(DialogInterface.OnDismissListener listener) {
        this.listener = listener;
    }

    @JavascriptInterface
    public void onLoaded(final String data) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                TencentCaptchaSender.getInstance().onLoaded(data);
            }
        };
        handler.post(runnable);
    }

    @JavascriptInterface
    public void onSuccess(final String data) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                TencentCaptchaSender.getInstance().onSuccess(data);

                listener.onDismiss(null);
            }
        };
        handler.post(runnable);
    }

    @JavascriptInterface
    public void onFail(final String data) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                TencentCaptchaSender.getInstance().onFail(data);
                listener.onDismiss(null);
            }
        };
        handler.post(runnable);
    }
}

public class TencentCaptchaActivity extends Activity implements DialogInterface.OnDismissListener {
    private TencentCaptchaConfig config;

    private WebView webView;
    private WebSettings webSettings;
    private WebViewClient webViewClient = new WebViewClient() {
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
        }

        @RequiresApi(api = Build.VERSION_CODES.KITKAT)
        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);

            String jsCode = String.format("window._verify(\"%s\");", config.appId);
            webView.evaluateJavascript(jsCode, new ValueCallback<String>() {
                @Override
                public void onReceiveValue(String value) {

                }
            });
        }
    };

    @SuppressLint({"ResourceAsColor", "SetJavaScriptEnabled"})
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);

        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN;
        decorView.setSystemUiVisibility(uiOptions);

        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        this.webView = new WebView(this);
//        this.addContentView(this.webView, layoutParams);
        this.setContentView(this.webView);

        this.webView.setBackgroundColor(android.R.color.transparent);
        this.webView.setWebViewClient(this.webViewClient);
        this.webView.addJavascriptInterface(new TencentCaptchaJsInterface(this), "messageHandlers");

        this.webSettings = this.webView.getSettings();
        this.webSettings.setJavaScriptEnabled(true);
        this.webView.requestFocus();

        Intent intent = getIntent();
        if (intent.hasExtra("config")) {
            this.config = (TencentCaptchaConfig) intent.getSerializableExtra("config");
        }
        if (intent.hasExtra("captchaHtmlPath")) {
            String captchaHtmlPath = intent.getStringExtra("captchaHtmlPath");
            this.webView.loadUrl("file:///android_asset/" + captchaHtmlPath);
        }
    }

    @Override
    protected void onPause() {
        overridePendingTransition(0, 0);
        super.onPause();
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        this.finish();
    }
}
