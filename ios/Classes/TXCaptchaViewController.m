//
//  TXCaptchaViewController.m
//  flutter_tencent_captcha
//
//  Created by Lijy91 on 2020/8/3.
//

#import "TXCaptchaViewController.h"
@import WebKit;

@interface TXCaptchaViewController ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, assign) NSString* captchaHtmlPath;
@property (nonatomic, strong) NSString* configJsonString;
@property (nonatomic, strong) TXCaptchaWebView* webView;
@property (nonatomic, strong) WKWebViewConfiguration * webViewConfiguration;
@end

@implementation TXCaptchaViewController

- (instancetype)initWithConfig:(NSString*)configJsonString captchaHtmlPath:(NSString*) path
{
    self = [super init];
    if (self) {
        self.configJsonString = configJsonString;
        self.captchaHtmlPath = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.webView = [[TXCaptchaWebView alloc] initWithFrame:self.view.frame configuration:self.webViewConfiguration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = false;
    
    [self.view addSubview:self.webView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURL* url = [NSURL fileURLWithPath:self.captchaHtmlPath];
    
    if (@available(iOS 9.0, *)) {
        [self.webView loadFileURL:url allowingReadAccessToURL:url];
    } else {
        // Fallback on earlier versions
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.webView = nil;
    self.webViewConfiguration = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(WKWebViewConfiguration*) webViewConfiguration {
    if (!_webViewConfiguration) {
        // Create WKWebViewConfiguration instance
        _webViewConfiguration = [[WKWebViewConfiguration alloc]init];
        
        WKUserContentController* userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self name:@"onLoaded"];
        [userContentController addScriptMessageHandler:self name:@"onSuccess"];
        [userContentController addScriptMessageHandler:self name:@"onFail"];
        
        _webViewConfiguration.userContentController = userContentController;
        
        _webViewConfiguration.preferences.javaScriptEnabled = YES;
        _webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    }
    return _webViewConfiguration;
    
}

#pragma mark -WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    NSDictionary *messageBody = message.body;
    
    if ([message.name isEqualToString:@"onLoaded"]) {
        self.onLoaded(messageBody);
    } else if ([message.name isEqualToString:@"onSuccess"]) {
        self.onSuccess(messageBody);
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if ([message.name isEqualToString:@"onFail"]) {
        self.onFail(messageBody);
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *jsCode = [NSString stringWithFormat:@"window._verify('%@');", self.configJsonString];
    [self.webView evaluateJavaScript:jsCode completionHandler:^(id response, NSError * _Nullable error) {
        // skip
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    if (navigationAction.request.URL) {
        
        NSURL *url = navigationAction.request.URL;
        NSString *urlPath = url.absoluteString;
        if ([urlPath rangeOfString:@"https://"].location != NSNotFound || [urlPath rangeOfString:@"http://"].location != NSNotFound) {
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    return nil;
}

@end
