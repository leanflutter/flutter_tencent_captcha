#import "FlutterTencentCaptchaPlugin.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation FlutterTencentCaptchaPlugin {
    FlutterEventSink _eventSink;
    NSString* captchaHtmlPath;
    NSString* appId;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_tencent_captcha"
                                     binaryMessenger:[registrar messenger]];
    
    
    NSString* captchaHtmlKey = [registrar lookupKeyForAsset:@"assets/captcha.html" fromPackage:@"flutter_tencent_captcha"];
    NSString* captchaHtmlPath = [[NSBundle mainBundle] pathForResource:captchaHtmlKey ofType:nil];
    
    FlutterTencentCaptchaPlugin* instance = [[FlutterTencentCaptchaPlugin alloc] initWithCaptchaHtmlPath:captchaHtmlPath];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* eventChannel =
    [FlutterEventChannel eventChannelWithName:@"flutter_tencent_captcha/event_channel"
                              binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

- (instancetype)initWithCaptchaHtmlPath:(NSString*)captchaHtmlPath
{
    self = [super init];
    if (self) {
        self->captchaHtmlPath = captchaHtmlPath;
    }
    return self;
}


- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    
    return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getSDKVersion" isEqualToString:call.method]) {
        [self handleMethodGetSDKVersion:call result:result];
    } else if ([@"init" isEqualToString:call.method]) {
        [self handleMethodInit:call result:result];
    } else if ([@"verify" isEqualToString:call.method]) {
        [self handleMethodVerify:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)handleMethodGetSDKVersion:(FlutterMethodCall*)call
                           result:(FlutterResult)result
{
    NSString *sdkVersion = @"0.0.1";
    
    result(sdkVersion);
}

- (void)handleMethodInit:(FlutterMethodCall*)call
                  result:(FlutterResult)result
{
    self->appId = call.arguments[@"appId"];
    
    result([NSNumber numberWithBool:YES]);
}

- (void)handleMethodVerify:(FlutterMethodCall*)call
                    result:(FlutterResult)result
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    NSObject *bizState = call.arguments[@"bizState"];
    NSNumber *enableDarkMode = call.arguments[@"enableDarkMode"];
    NSDictionary *sdkOpts = call.arguments[@"sdkOpts"];
    
    TXCaptchaConfigModel* configModel = [[TXCaptchaConfigModel alloc] init];
    configModel.captchaHtmlPath = self->captchaHtmlPath;
    configModel.appId = self->appId;
    
    if (bizState)
        configModel.bizState = bizState;
    if (enableDarkMode)
        configModel.enableDarkMode = enableDarkMode.boolValue;
    if (sdkOpts)
        configModel.sdkOpts = sdkOpts;
    
    TXCaptchaViewController *controller = [[TXCaptchaViewController alloc] initWithConfigModel: configModel];
    [controller setModalPresentationStyle: UIModalPresentationOverFullScreen];
    controller.onLoaded = ^(NSDictionary * _Nonnull data) {
        NSDictionary<NSString *, id> *eventData = @{
            @"method": @"onLoaded",
            @"data": data,
        };
        self->_eventSink(eventData);
    };
    controller.onSuccess = ^(NSDictionary * _Nonnull data) {
        NSDictionary<NSString *, id> *eventData = @{
            @"method": @"onSuccess",
            @"data": data,
        };
        self->_eventSink(eventData);
    };
    controller.onFail = ^(NSDictionary * _Nonnull data) {
        NSDictionary<NSString *, id> *eventData = @{
            @"method": @"onFail",
            @"data": data,
        };
        self->_eventSink(eventData);
    };
    
    [rootViewController presentViewController:controller animated:NO completion:nil];
    result([NSNumber numberWithBool:YES]);
}

@end
