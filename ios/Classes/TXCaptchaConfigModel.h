//
//  TXCatchaConfigModel.h
//  flutter_tencent_captcha
//
//  Created by Lijy91 on 2020/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXCaptchaConfigModel : NSObject

@property (nonatomic, assign) NSString* captchaHtmlPath;

/**
 AppId
 */
@property (nonatomic, assign) NSString* appId;

/**
 自定义透传参数，业务可用该字段传递少量数据，该字段的内容会被带入callback回调的对象中
 */
@property (nonatomic, assign) NSObject* bizState;

/**
 开启自适应深夜模式
 */
@property (nonatomic, assign) BOOL enableDarkMode;

/**
 SDK 选项
 */
@property (nonatomic, assign) NSDictionary *sdkOpts;

@end

NS_ASSUME_NONNULL_END
