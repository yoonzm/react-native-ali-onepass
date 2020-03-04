
#import "RNNeteaseQuickpass.h"

@implementation RNNeteaseQuickpass {
    NSString *token;
    NTESQuickLoginManager *quickLogin;
    NTESQuickLoginCMModel *cmLoginUiConfig;
    NTESQuickLoginCUModel *cuLoginUiConfig;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(NSString *)businessId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    quickLogin = [NTESQuickLoginManager sharedInstance];
    // 在使用一键登录之前，请先调用shouldQuickLogin方法，判断当前上网卡的网络环境和运营商是否可以一键登录，若可以一键登录，继续执行下面的步骤；否则，建议后续直接走降级方案（例如短信）
    BOOL shouldQL = [quickLogin shouldQuickLogin];
    if (!shouldQL) {
        reject(0, @"当前环境不支持一键登录，建议走降级方案", nil);
        return;
    }
    [quickLogin registerWithBusinessID:businessId timeout:10*1000 completion:^(NSDictionary * _Nullable params, BOOL success) {
        if (success) {
            // 初始化成功，获取token
            token = [params objectForKey:@"token"];
            [self initUiConfig];
            resolve(token);
        } else {
            // 初始化失败
            reject(0, @"初始化失败", nil);
        }
    }];
}

-(void)initUiConfig {
    // 移动
    cmLoginUiConfig = [[NTESQuickLoginCMModel alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^(){
        cmLoginUiConfig.currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    });
    cmLoginUiConfig.presentType = NTESCMPresentationDirectionRight;
    cmLoginUiConfig.navText = [[NSAttributedString alloc]initWithString:@"一键登录"];
    cmLoginUiConfig.navColor = UIColor.whiteColor;
    cmLoginUiConfig.privacyState = YES;
    [quickLogin setupCMModel:cmLoginUiConfig];
    // 联通
    cuLoginUiConfig = [[NTESQuickLoginCUModel alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^(){
        cuLoginUiConfig.currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    });
    cuLoginUiConfig.navText = @"一键登录";
//    cuLoginUiConfig.controllerType = NTESCUPushController;
    /* 在此处进行自定义，可自定义项参见NTESQuickLoginCUModel.h */
    [quickLogin setupCUModel:cuLoginUiConfig];
}

RCT_EXPORT_METHOD(prefetch:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [quickLogin getPhoneNumberCompletion:^(NSDictionary * _Nonnull resultDic) {
        NSNumber *boolNum = [resultDic objectForKey:@"success"];
        BOOL success = [boolNum boolValue];
        if (success) {
            // 电信获取脱敏手机号成功
            // 移动、联通无脱敏手机号，需在此回调中拉去授权登录页面
            NSString *phone = [resultDic objectForKey:@"securityPhone"];
            resolve(phone);
        } else {
            // 电信获取脱敏手机号失败
            // 移动、联通预取号失败
            reject([resultDic objectForKey:@"resultCode"], [resultDic objectForKey:@"desc"], nil);
        }
    }];
}

RCT_EXPORT_METHOD(onePass:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 获取当前上网卡的运营商，1:电信 2.移动 3.联通
    NSInteger type = [quickLogin getCarrier];
    if (type == 1) {
        [[NTESQuickLoginManager sharedInstance] CTAuthorizeLoginCompletion:^(NSDictionary * _Nonnull resultDic) {
            NSNumber *boolNum = [resultDic objectForKey:@"success"];
            BOOL success = [boolNum boolValue];
            if (success) {
                // 取号成功，获取acessToken
                NSString *accessToken = [resultDic objectForKey:@"accessToken"];
                NSMutableDictionary *params = @{}.mutableCopy;
                params[@"accessToken"] = accessToken;
                params[@"token"] = token;
                resolve(params);
            } else {
                // 取号失败
                reject([resultDic objectForKey:@"resultCode"], [resultDic objectForKey:@"desc"], nil);
            }
        }];
    } else if (type == 2) {
        [[NTESQuickLoginManager sharedInstance] CUCMAuthorizeLoginCompletion:^(NSDictionary * _Nonnull resultDic) {
            NSNumber *boolNum = [resultDic objectForKey:@"success"];
            BOOL success = [boolNum boolValue];
            if (success) {
                // 取号成功，获取acessToken
                NSString *accessToken = [resultDic objectForKey:@"accessToken"];
                NSMutableDictionary *params = @{}.mutableCopy;
                params[@"accessToken"] = accessToken;
                params[@"token"] = token;
                resolve(params);
            } else {
                NSString *resultCode = [resultDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"200020"]) {
                    [self sendEventWithName:@"onCancelGetToken" body:nil];
                    return;
                } else if([resultCode isEqualToString:@"200060"]) {
                    // 切换账号不会自动关闭页面 需要手动处理
                    [[UIApplication sharedApplication].keyWindow.rootViewController.navigationController popToRootViewControllerAnimated:true];
                    [self sendEventWithName:@"onOtherLoginClick" body:nil];
                    return;
                }
                // 取号失败
                reject(resultCode, [resultDic objectForKey:@"desc"], nil);
            }
        }];
    } else {
        // 联通
        [[NTESQuickLoginManager sharedInstance] CUCMAuthorizeLoginCompletion:^(NSDictionary * _Nonnull resultDic) {
            NSNumber *boolNum = [resultDic objectForKey:@"success"];
            BOOL success = [boolNum boolValue];
            if (success) {
                // 取号成功，获取acessToken
                NSString *accessToken = [resultDic objectForKey:@"accessToken"];
                NSMutableDictionary *params = @{}.mutableCopy;
                params[@"accessToken"] = accessToken;
                params[@"token"] = token;
                resolve(params);
            } else {
                NSString *resultCode = [resultDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"10104"]) {
                    [self sendEventWithName:@"onCancelGetToken" body:nil];
                    return;
                } else if([resultCode isEqualToString:@"10105"]) {
                    [self sendEventWithName:@"onOtherLoginClick" body:nil];
                    return;
                }
                // 取号失败
                reject(resultCode, [resultDic objectForKey:@"desc"], nil);
            }
        }];
    }
}

RCT_EXPORT_METHOD(getOperatorType:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 获取当前上网卡的运营商，1:电信 2.移动 3.联通
    NSInteger type = [quickLogin getCarrier];
    NSString *typeName = @"未知";
    if (type == 1) {
        typeName = @"电信";
    } else if (type == 2) {
        typeName = @"移动";
    }else if (type == 3) {
        typeName = @"联通";
    }
    resolve(typeName);
}

RCT_EXPORT_METHOD(setLogo:(NSString *)logoPath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
   cmLoginUiConfig.logoImg =[UIImage imageWithContentsOfFile:logoPath];
    // 联通
    cuLoginUiConfig.logoImg = [UIImage imageWithContentsOfFile:logoPath];
    resolve(@"");
}

RCT_EXPORT_METHOD(setMobileMaskNumber:(NSString *)color textSize:(NSInteger *)textSize resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
    // 联通
    cuLoginUiConfig.numberColor = [self colorWithHexString:color];
    cuLoginUiConfig.numberFont = [UIFont fontWithName:nil size: 25];
//    cuLoginUiConfig.numberOffsetY = -40;
    resolve(@"");
}

RCT_EXPORT_METHOD(setBrand:(NSString *)color resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
//    cmLoginUiConfig.
    // 联通
    cuLoginUiConfig.brandColor = [self colorWithHexString:color];
    cuLoginUiConfig.brandOffsetY = 50;
    resolve(@"");
}

RCT_EXPORT_METHOD(setLoginButton:(NSInteger *)width height:(NSInteger)height text:(NSString *)text bgColor:(NSString *)bgColor bgImage:(NSString *)bgImage resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
    cmLoginUiConfig.logBtnText = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName: UIColor.whiteColor}];
    UIImage *loginBtnImage = [[UIImage alloc]initWithContentsOfFile:bgImage];
    cmLoginUiConfig.logBtnImgs = @[loginBtnImage, loginBtnImage, loginBtnImage];
//    cmLoginUiConfig.logBt
    // 联通
    cuLoginUiConfig.logBtnText = text;
    cuLoginUiConfig.logBtnRadius = 4;
    cuLoginUiConfig.logBtnUnusableBGColor = [self colorWithHexString:bgColor];
    cuLoginUiConfig.logBtnUsableBGColor = [self colorWithHexString:bgColor];
    resolve(@"");
}

RCT_EXPORT_METHOD(setOtherLoginButton:(NSString *)text color:(NSString *)color bold:(BOOL *)bold isShow:(BOOL *)isShow resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
    cmLoginUiConfig.switchAccText = [[NSAttributedString alloc]initWithString:text attributes:@{
                                                                                                NSForegroundColorAttributeName: [self colorWithHexString:color],
                                                                                                NSFontAttributeName: [UIFont systemFontOfSize:12.0f]
                                                                                                }];
//    cmLoginUiConfig.switchOffsetY = 20;
    // 联通
    cuLoginUiConfig.switchText = text;
    cuLoginUiConfig.swithAccTextColor = [self colorWithHexString:color];
    cuLoginUiConfig.swithAccOffsetX = 160;
    cuLoginUiConfig.swithAccOffsetY = 20;
    resolve(@"");
}

RCT_EXPORT_METHOD(setProtocol:(NSString *)text1 link1:(NSString *)link1 text2:(NSString *)text2 link2:(NSString *)link2 color:(NSString *)color resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    // 移动
    NSString *demoText = [[NSString alloc] initWithFormat:@"登录即同意&&默认&&和%@、%@进行本机号码登录", text1, text2];
    cmLoginUiConfig.appPrivacyDemo = [[NSAttributedString alloc]initWithString:demoText attributes:@{NSForegroundColorAttributeName:[self colorWithHexString:@"#B2B2B2"]}];
    NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:text1 attributes:@{NSLinkAttributeName:link1}];
    NSAttributedString *str2 = [[NSAttributedString alloc]initWithString:text2 attributes:@{NSLinkAttributeName:link2}];
    cmLoginUiConfig.appPrivacy = @[str1, str2];
    cmLoginUiConfig.privacyColor = [self colorWithHexString:color];
//    cmLoginUiConfig
    // 联通
    cuLoginUiConfig.appFPrivacyText = text1;
    cuLoginUiConfig.appFPrivacyURL = [NSURL URLWithString:link1];
    cuLoginUiConfig.appSPrivacyText = text2;
    cuLoginUiConfig.appSPrivacyURL = [NSURL URLWithString:link2];
    cuLoginUiConfig.privacyColor = [self colorWithHexString:color];
    cuLoginUiConfig.checkBoxHidden = YES;
    resolve(@"");
}

- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

-(NSArray<NSString *> *)supportedEvents {
    return @[@"onCancelGetToken", @"onOtherLoginClick"];
}

@end
