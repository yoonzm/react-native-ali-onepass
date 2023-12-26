
#import "RNAliOnepass.h"

#define TX_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define TX_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define IS_HORIZONTAL (TX_SCREEN_WIDTH > TX_SCREEN_WIDTH)

#define TX_Alert_NAV_BAR_HEIGHT      55.0
#define TX_Alert_HORIZONTAL_NAV_BAR_HEIGHT      41.0

//竖屏弹窗
#define TX_Alert_Default_Left_Padding         42
#define TX_Alert_Default_Top_Padding          115

/**横屏弹窗*/
#define TX_Alert_Horizontal_Default_Left_Padding      80.0


@implementation RNAliOnepass {
    TXCommonHandler *tXCommonHandler;
    NSInteger *prefetchNumberTimeout;
    TXCustomModel *tXCustomModel;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(NSString *)secretInfo resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    tXCommonHandler = [TXCommonHandler sharedInstance];
    [tXCommonHandler setAuthSDKInfo:secretInfo complete:^(NSDictionary * _Nonnull resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if([resultCode isEqualToString:PNSCodeSuccess]) {
            resolve(@"");
        } else {
            reject(resultCode, [resultDic objectForKey:@"msg"], nil);
        }
    }];
}

// 判断是否初始化过
-(BOOL)checkInit:(RCTPromiseRejectBlock)reject {
    if(tXCommonHandler == nil) {
        reject(@"0", @"请先调用初始化接口init", nil);
        return false;
    }
    return true;
}

// 检查认证环境 第一次或者切换网络后需要重新调用
RCT_EXPORT_METHOD(checkEnvAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(![self checkInit:reject]){
        return;
    }
    [tXCommonHandler checkEnvAvailableWithAuthType:PNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if([resultCode isEqualToString:PNSCodeSuccess]) {
            resolve(@"");
        } else {
            reject(resultCode, [resultDic objectForKey:@"msg"], nil);
        }
    }];
}

// 预取号 加速页面弹起
RCT_EXPORT_METHOD(prefetch:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(![self checkInit:reject]){
        return;
    }
    [tXCommonHandler accelerateLoginPageWithTimeout:0.0 complete:^(NSDictionary * _Nonnull resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if([resultCode isEqualToString:PNSCodeSuccess]) {
            resolve(@"");
        } else {
            reject(resultCode, [resultDic objectForKey:@"msg"], nil);
        }
    }];
}

// 一键登录 页面弹起
RCT_EXPORT_METHOD(onePass:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(![self checkInit:reject]){
        return;
    }
    [tXCommonHandler getLoginTokenWithTimeout:0.0 controller:[UIApplication sharedApplication].keyWindow.rootViewController model:tXCustomModel complete:^(NSDictionary * _Nonnull resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        NSString *msg = [resultDic objectForKey:@"msg"];
        NSString *token = [resultDic objectForKey:@"token"];
        if([resultCode isEqualToString:PNSCodeSuccess]
        ||[resultCode isEqualToString:PNSCodeLoginControllerPresentSuccess]
           || [resultCode isEqualToString:PNSCodeLoginControllerClickLoginBtn]
           || [resultCode isEqualToString:PNSCodeLoginControllerClickCheckBoxBtn]
           || [resultCode isEqualToString:PNSCodeLoginControllerClickProtocol]
           ) {
            [self sendEventWithName:@"onTokenSuccess" body:@{
                                                             @"msg": msg!=nil ? msg: @"",
                                                             @"code": resultCode!=nil?resultCode:@"",
                                               @"token": token!=nil ? token : @""
                                               }];
        } else {
            [self sendEventWithName:@"onTokenFailed" body:@{
                                                            @"msg": msg!=nil ? msg: @"",
                                                            @"code": resultCode!=nil?resultCode:@"",
                                               }];
        }
    }];
    resolve(@"");
}

// 退出登录授权
RCT_EXPORT_METHOD(quitLoginPage:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    [tXCommonHandler cancelLoginVCAnimated:true complete:^{
        resolve(@"");
    }];
}

// 授权⻚的 loading
RCT_EXPORT_METHOD(hideLoginLoading:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    [tXCommonHandler hideLoginLoading];
    resolve(@"");
}

// 运行商类型 中国移动/中国联通/中国电信
RCT_EXPORT_METHOD(getOperatorType:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    NSString *type = [TXCommonUtils getCurrentCarrierName];
    resolve(type);
}

// 将方法名转为key名 主要是和安卓端的逻辑保持一致
-(NSString *)methodName2KeyName:(NSString *)methodName {
    NSString *result = @"";
    if(methodName == nil) {
        return result;
    }
    if ([methodName hasPrefix:@"set"]) {
        result = [methodName substringFromIndex:3];
    }
    NSString *firstChar = [result substringWithRange:NSMakeRange(0, 1)];
    NSString *otherChar = [result substringFromIndex:1];
    return [[firstChar lowercaseString] stringByAppendingString:otherChar];
}

// 设置UI
RCT_EXPORT_METHOD(setUIConfig:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"config = %@", config);
    tXCustomModel = [[TXCustomModel alloc] init];
    // 状态栏
    NSString *statusBarHidden = [config objectForKey:[self methodName2KeyName:@"setStatusBarHidden"]];
    if (statusBarHidden != nil) {
        tXCustomModel.prefersStatusBarHidden = [statusBarHidden boolValue];
    }
    // 标题栏
    NSString *navColor = [config objectForKey:[self methodName2KeyName:@"setNavColor"]];
    if (navColor != nil) {
        tXCustomModel.navColor = [self colorWithHexString:navColor];
    }
    NSString *navText = [config objectForKey:[self methodName2KeyName:@"setNavText"]];
    NSString *navTextColor = [config objectForKey:[self methodName2KeyName:@"setNavTextColor"]];
    NSString *navTextSize = [config objectForKey:[self methodName2KeyName:@"setNavTextSize"]];
    if (navText != nil && navTextColor != nil && navTextSize != nil) {
        tXCustomModel.navTitle = [[NSAttributedString alloc]initWithString:navText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:navTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[navTextSize doubleValue]]}];
    }
    NSString *navReturnImgPath = [config objectForKey:[self methodName2KeyName:@"setNavReturnImgPath"]];
    if (navReturnImgPath != nil) {
        tXCustomModel.navBackImage = [UIImage imageNamed:navReturnImgPath];
        tXCustomModel.privacyNavBackImage = [UIImage imageNamed:navReturnImgPath];
    }
    NSString *navReturnImgWidth = [config objectForKey:[self methodName2KeyName:@"setNavReturnImgWidth"]];
    NSString *navReturnImgHeight = [config objectForKey:[self methodName2KeyName:@"setNavReturnImgHeight"]];
    tXCustomModel.navBackButtonFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (navReturnImgWidth != nil) {
            width = [navReturnImgWidth floatValue];
        }
        if (navReturnImgHeight != nil) {
            height = [navReturnImgHeight floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // logo
    NSString *logoImgPath = [config objectForKey:[self methodName2KeyName:@"setLogoImgPath"]];
    if (logoImgPath != nil) {
        tXCustomModel.logoImage = [UIImage imageNamed:logoImgPath];
    }
    NSString *logoHidden = [config objectForKey:[self methodName2KeyName:@"setLogoHidden"]];
    if (logoHidden != nil) {
        tXCustomModel.logoIsHidden = [logoHidden boolValue];
    }

    NSString *alertlogoWidth = [config objectForKey:[self methodName2KeyName:@"setLogoWidth"]];
    NSString *alertlogoHeight = [config objectForKey:[self methodName2KeyName:@"setLogoHeight"]];

    CGFloat logoWidth = 30;
    CGFloat logoHeight = 30;
    if (alertlogoWidth != nil) {
        logoWidth = [alertlogoWidth floatValue];
    }
    if (alertlogoHeight != nil) {
        logoHeight = [alertlogoHeight floatValue];
    }

    NSString *logoOffsetY = [config objectForKey:[self methodName2KeyName:@"setLogoOffsetY"]];
    NSString *logoOffsetX = [config objectForKey:[self methodName2KeyName:@"setLogoOffsetX"]];

    tXCustomModel.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (logoOffsetY != nil) {
            y = [logoOffsetY floatValue];
        }
        if (logoOffsetX != nil) {
            x = [logoOffsetX floatValue];
        }
        return CGRectMake(x, y, logoWidth, logoHeight);
    };
    // number
    NSString *numberColor = [config objectForKey:[self methodName2KeyName:@"setNumberColor"]];
    if (numberColor != nil) {
        tXCustomModel.numberColor = [self colorWithHexString:numberColor];
    }
    NSString *numberSize = [config objectForKey:[self methodName2KeyName:@"setNumberSize"]];
    if (numberSize != nil) {
        tXCustomModel.numberFont = [UIFont systemFontOfSize:[numberSize floatValue]];
    }
    NSString *numberFieldOffsetX = [config objectForKey:[self methodName2KeyName:@"setNumberFieldOffsetX"]];
    NSString *numberFieldOffsetY = [config objectForKey:[self methodName2KeyName:@"setNumberFieldOffsetY"]];
    tXCustomModel.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (numberFieldOffsetX != nil) {
            x = [numberFieldOffsetY floatValue];
        }
        if (numberFieldOffsetY != nil) {
            y = [numberFieldOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // slogan
    NSString *sloganText = [config objectForKey:[self methodName2KeyName:@"setSloganText"]];
    NSString *sloganTextColor = [config objectForKey:[self methodName2KeyName:@"setSloganTextColor"]];
    NSString *sloganTextSize = [config objectForKey:[self methodName2KeyName:@"setSloganTextSize"]];
    if (sloganText != nil && sloganTextColor != nil && sloganTextSize != nil) {
        tXCustomModel.sloganText = [[NSAttributedString alloc]initWithString:sloganText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:sloganTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[sloganTextSize doubleValue]]}];
    }
    NSString *sloganOffsetY = [config objectForKey:[self methodName2KeyName:@"setSloganOffsetY"]];
    tXCustomModel.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (sloganOffsetY != nil) {
            y = [sloganOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // logBtn
    NSString *logBtnText = [config objectForKey:[self methodName2KeyName:@"setLogBtnText"]];
    NSString *logBtnTextColor = [config objectForKey:[self methodName2KeyName:@"setLogBtnTextColor"]];
    NSString *logBtnTextSize = [config objectForKey:[self methodName2KeyName:@"setLogBtnTextSize"]];
    if (logBtnText != nil && logBtnTextColor != nil && logBtnTextSize != nil) {
        tXCustomModel.loginBtnText = [[NSAttributedString alloc]initWithString:logBtnText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:logBtnTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[logBtnTextSize doubleValue]]}];
    }
    NSArray<NSString *> *logBtnBackgroundPaths = [config objectForKey:[self methodName2KeyName:@"setLogBtnBackgroundPaths"]];
    if (logBtnBackgroundPaths != nil) {
        tXCustomModel.loginBtnBgImgs = @[[UIImage imageNamed:logBtnBackgroundPaths[0]], [UIImage imageNamed:logBtnBackgroundPaths[1]], [UIImage imageNamed:logBtnBackgroundPaths[2]]];
    }
    tXCustomModel.autoHideLoginLoading = NO; // 与安卓保持一致
    NSString *logBtnMarginLeftAndRight = [config objectForKey:[self methodName2KeyName:@"setLogBtnMarginLeftAndRight"]];
    NSString *logBtnOffsetY = [config objectForKey:[self methodName2KeyName:@"setLogBtnOffsetY"]];
    tXCustomModel.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (logBtnOffsetY != nil) {
            y = [logBtnOffsetY floatValue];
        }
        if (logBtnMarginLeftAndRight != nil) {
            width = screenSize.width - [logBtnMarginLeftAndRight floatValue] * 2;
            x = [logBtnMarginLeftAndRight floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // switch
    NSString *switchAccText = [config objectForKey:[self methodName2KeyName:@"setSwitchAccText"]];
    NSString *switchAccTextColor = [config objectForKey:[self methodName2KeyName:@"setSwitchAccTextColor"]];
    NSString *switchAccTextSize = [config objectForKey:[self methodName2KeyName:@"setSwitchAccTextSize"]];
    if (switchAccText != nil && switchAccTextColor != nil && switchAccTextSize != nil) {
        tXCustomModel.changeBtnTitle = [[NSAttributedString alloc]initWithString:switchAccText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:switchAccTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[switchAccTextSize doubleValue]]}];
    }
    NSString *switchAccHidden = [config objectForKey:[self methodName2KeyName:@"setSwitchAccHidden"]];
    if (switchAccHidden != nil) {
        tXCustomModel.changeBtnIsHidden = [switchAccHidden boolValue];
    }
    NSString *switchOffsetY = [config objectForKey:[self methodName2KeyName:@"setSwitchOffsetY"]];
    tXCustomModel.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (switchOffsetY != nil) {
            y = [switchOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // orivacy
    tXCustomModel.privacyAlignment = NSTextAlignmentCenter; // 与安卓保持一致
    NSString *appPrivacyOneName = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyOneName"]];
    NSString *appPrivacyOneUrl = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyOneUrl"]];
    if (appPrivacyOneName != nil && appPrivacyOneUrl != nil) {
        tXCustomModel.privacyOne = @[appPrivacyOneName, appPrivacyOneUrl];
    }
    NSString *appPrivacyTwoName = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyTwoName"]];
    NSString *appPrivacyTwoUrl = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyTwoUrl"]];
    if (appPrivacyTwoName != nil && appPrivacyTwoUrl != nil) {
        tXCustomModel.privacyTwo = @[appPrivacyTwoName, appPrivacyTwoUrl];
    }
    NSString *privacyState = [config objectForKey:[self methodName2KeyName:@"setPrivacyState"]];
    if (privacyState != nil) {
        tXCustomModel.checkBoxIsChecked = [privacyState boolValue];
    }
    NSString *privacyTextSize = [config objectForKey:[self methodName2KeyName:@"setPrivacyTextSize"]];
    if (privacyTextSize != nil) {
        tXCustomModel.privacyFont = [UIFont systemFontOfSize:[privacyTextSize floatValue]];
    }
    NSString *appPrivacyBaseColor = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyBaseColor"]];
    NSString *appPrivacyColor = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyColor"]];
    if (appPrivacyBaseColor != nil && appPrivacyColor != nil) {
        tXCustomModel.privacyColors = @[[self colorWithHexString:appPrivacyBaseColor], [self colorWithHexString:appPrivacyColor]];
    }
    NSString *vendorPrivacyPrefix = [config objectForKey:[self methodName2KeyName:@"setVendorPrivacyPrefix"]];
    NSString *vendorPrivacySuffix = [config objectForKey:[self methodName2KeyName:@"setVendorPrivacySuffix"]];
    if (vendorPrivacyPrefix != nil) {
        tXCustomModel.privacyOperatorPreText = vendorPrivacyPrefix;
    }
    if (vendorPrivacySuffix != nil) {
        tXCustomModel.privacyOperatorSufText = vendorPrivacySuffix;
    }
    NSString *privacyBefore = [config objectForKey:[self methodName2KeyName:@"setPrivacyBefore"]];
    NSString *privacyEnd = [config objectForKey:[self methodName2KeyName:@"setPrivacyEnd"]];
    if (privacyBefore != nil) {
        tXCustomModel.privacyPreText = privacyBefore;
    }
    if (vendorPrivacySuffix != nil) {
        tXCustomModel.privacySufText = privacyEnd;
    }
    NSString *checkboxHidden = [config objectForKey:[self methodName2KeyName:@"setCheckboxHidden"]];
    if (checkboxHidden != nil) {
        tXCustomModel.checkBoxIsHidden = [checkboxHidden boolValue];
    }
    NSString *privacyBottomOffsetY = [config objectForKey:[self methodName2KeyName:@"setPrivacyBottomOffsetY"]];
    tXCustomModel.privacyFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (privacyBottomOffsetY != nil) {
            y = y - [privacyBottomOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    resolve(@"");
}


// 设置UI
RCT_EXPORT_METHOD(setDialogUIConfig:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"config = %@", config);
    tXCustomModel = [[TXCustomModel alloc] init];
    tXCustomModel.alertCornerRadiusArray = @[@10, @10, @10, @10];
    // 状态栏
    NSString *statusBarHidden = [config objectForKey:[self methodName2KeyName:@"setStatusBarHidden"]];
    if (statusBarHidden != nil) {
        tXCustomModel.prefersStatusBarHidden = [statusBarHidden boolValue];
    }

    NSString *dialogHeightDelta = [config objectForKey:[self methodName2KeyName:@"setDialogHeightDelta"]];

    CGFloat ratio = MAX(TX_SCREEN_WIDTH, TX_SCREEN_HEIGHT) / 667.0;
    tXCustomModel.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        CGFloat alertX = 0;
        CGFloat alertY = 0;
        CGFloat alertWidth = 0;
        CGFloat alertHeight = 0;

        if ([self isHorizontal:screenSize]) {
            alertX = ratio * TX_Alert_Horizontal_Default_Left_Padding;
            alertWidth = screenSize.width - alertX * 2;
            alertY = (screenSize.height - alertWidth * 0.5) * 0.5;
            alertHeight = screenSize.height - 2 * alertY;
        } else {
            alertX = TX_Alert_Default_Left_Padding * ratio;
            alertWidth = screenSize.width - alertX * 2;
            alertY = TX_Alert_Default_Top_Padding * ratio;
            alertHeight = screenSize.height - alertY * 2 - [dialogHeightDelta floatValue];
        }
        return CGRectMake(alertX, alertY, alertWidth, alertHeight);
    };
    // logo
    NSString *logoImgPath = [config objectForKey:[self methodName2KeyName:@"setLogoImgPath"]];
    if (logoImgPath != nil) {
        tXCustomModel.logoImage = [UIImage imageNamed:logoImgPath];
    }
    NSString *logoHidden = [config objectForKey:[self methodName2KeyName:@"setLogoHidden"]];
    if (logoHidden != nil) {
        tXCustomModel.logoIsHidden = [logoHidden boolValue];
    }
    NSString *logoOffsetY = [config objectForKey:[self methodName2KeyName:@"setLogoOffsetY"]];
    tXCustomModel.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (logoOffsetY != nil) {
            y = [logoOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // number
    NSString *numberColor = [config objectForKey:[self methodName2KeyName:@"setNumberColor"]];
    if (numberColor != nil) {
        tXCustomModel.numberColor = [self colorWithHexString:numberColor];
    }
    NSString *numberSize = [config objectForKey:[self methodName2KeyName:@"setNumberSize"]];
    if (numberSize != nil) {
        tXCustomModel.numberFont = [UIFont systemFontOfSize:[numberSize floatValue]];
    }
    NSString *numberFieldOffsetX = [config objectForKey:[self methodName2KeyName:@"setNumberFieldOffsetX"]];
    NSString *numberFieldOffsetY = [config objectForKey:[self methodName2KeyName:@"setNumberFieldOffsetY"]];
    tXCustomModel.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (numberFieldOffsetX != nil) {
            x = [numberFieldOffsetY floatValue];
        }
        if (numberFieldOffsetY != nil) {
            y = [numberFieldOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // slogan
    NSString *sloganText = [config objectForKey:[self methodName2KeyName:@"setSloganText"]];
    NSString *sloganTextColor = [config objectForKey:[self methodName2KeyName:@"setSloganTextColor"]];
    NSString *sloganTextSize = [config objectForKey:[self methodName2KeyName:@"setSloganTextSize"]];
    if (sloganText != nil && sloganTextColor != nil && sloganTextSize != nil) {
        tXCustomModel.sloganText = [[NSAttributedString alloc]initWithString:sloganText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:sloganTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[sloganTextSize doubleValue]]}];
    }
    NSString *sloganOffsetY = [config objectForKey:[self methodName2KeyName:@"setSloganOffsetY"]];
    tXCustomModel.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (sloganOffsetY != nil) {
            y = [sloganOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // logBtn
    NSString *logBtnText = [config objectForKey:[self methodName2KeyName:@"setLogBtnText"]];
    NSString *logBtnTextColor = [config objectForKey:[self methodName2KeyName:@"setLogBtnTextColor"]];
    NSString *logBtnTextSize = [config objectForKey:[self methodName2KeyName:@"setLogBtnTextSize"]];
    if (logBtnText != nil && logBtnTextColor != nil && logBtnTextSize != nil) {
        tXCustomModel.loginBtnText = [[NSAttributedString alloc]initWithString:logBtnText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:logBtnTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[logBtnTextSize doubleValue]]}];
    }
    NSArray<NSString *> *logBtnBackgroundPaths = [config objectForKey:[self methodName2KeyName:@"setLogBtnBackgroundPaths"]];
    if (logBtnBackgroundPaths != nil) {
        tXCustomModel.loginBtnBgImgs = @[[UIImage imageNamed:logBtnBackgroundPaths[0]], [UIImage imageNamed:logBtnBackgroundPaths[1]], [UIImage imageNamed:logBtnBackgroundPaths[2]]];
    }
    tXCustomModel.autoHideLoginLoading = NO; // 与安卓保持一致
    NSString *logBtnMarginLeftAndRight = [config objectForKey:[self methodName2KeyName:@"setLogBtnMarginLeftAndRight"]];
    NSString *logBtnOffsetY = [config objectForKey:[self methodName2KeyName:@"setLogBtnOffsetY"]];
    tXCustomModel.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (logBtnOffsetY != nil) {
            y = [logBtnOffsetY floatValue];
        }
        if (logBtnMarginLeftAndRight != nil) {
            width = screenSize.width - [logBtnMarginLeftAndRight floatValue] * 2;
            x = [logBtnMarginLeftAndRight floatValue] / 2;
        }
        return CGRectMake(x, y, width, height);
    };
    // switch
    NSString *switchAccText = [config objectForKey:[self methodName2KeyName:@"setSwitchAccText"]];
    NSString *switchAccTextColor = [config objectForKey:[self methodName2KeyName:@"setSwitchAccTextColor"]];
    NSString *switchAccTextSize = [config objectForKey:[self methodName2KeyName:@"setSwitchAccTextSize"]];
    if (switchAccText != nil && switchAccTextColor != nil && switchAccTextSize != nil) {
        tXCustomModel.changeBtnTitle = [[NSAttributedString alloc]initWithString:switchAccText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:switchAccTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[switchAccTextSize doubleValue]]}];
    }
    NSString *switchAccHidden = [config objectForKey:[self methodName2KeyName:@"setSwitchAccHidden"]];
    if (switchAccHidden != nil) {
        tXCustomModel.changeBtnIsHidden = [switchAccHidden boolValue];
    }
    NSString *switchOffsetY = [config objectForKey:[self methodName2KeyName:@"setSwitchOffsetY"]];
    tXCustomModel.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (switchOffsetY != nil) {
            y = [switchOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };
    // orivacy
    tXCustomModel.privacyAlignment = NSTextAlignmentCenter; // 与安卓保持一致
    NSString *appPrivacyOneName = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyOneName"]];
    NSString *appPrivacyOneUrl = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyOneUrl"]];
    if (appPrivacyOneName != nil && appPrivacyOneUrl != nil) {
        tXCustomModel.privacyOne = @[appPrivacyOneName, appPrivacyOneUrl];
    }
    NSString *appPrivacyTwoName = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyTwoName"]];
    NSString *appPrivacyTwoUrl = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyTwoUrl"]];
    if (appPrivacyTwoName != nil && appPrivacyTwoUrl != nil) {
        tXCustomModel.privacyTwo = @[appPrivacyTwoName, appPrivacyTwoUrl];
    }
    NSString *privacyState = [config objectForKey:[self methodName2KeyName:@"setPrivacyState"]];
    if (privacyState != nil) {
        tXCustomModel.checkBoxIsChecked = [privacyState boolValue];
    }
    NSString *privacyTextSize = [config objectForKey:[self methodName2KeyName:@"setPrivacyTextSize"]];
    if (privacyTextSize != nil) {
        tXCustomModel.privacyFont = [UIFont systemFontOfSize:[privacyTextSize floatValue]];
    }
    NSString *appPrivacyBaseColor = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyBaseColor"]];
    NSString *appPrivacyColor = [config objectForKey:[self methodName2KeyName:@"setAppPrivacyColor"]];
    if (appPrivacyBaseColor != nil && appPrivacyColor != nil) {
        tXCustomModel.privacyColors = @[[self colorWithHexString:appPrivacyBaseColor], [self colorWithHexString:appPrivacyColor]];
    }
    NSString *vendorPrivacyPrefix = [config objectForKey:[self methodName2KeyName:@"setVendorPrivacyPrefix"]];
    NSString *vendorPrivacySuffix = [config objectForKey:[self methodName2KeyName:@"setVendorPrivacySuffix"]];
    if (vendorPrivacyPrefix != nil) {
        tXCustomModel.privacyOperatorPreText = vendorPrivacyPrefix;
    }
    if (vendorPrivacySuffix != nil) {
        tXCustomModel.privacyOperatorSufText = vendorPrivacySuffix;
    }
    NSString *privacyBefore = [config objectForKey:[self methodName2KeyName:@"setPrivacyBefore"]];
    NSString *privacyEnd = [config objectForKey:[self methodName2KeyName:@"setPrivacyEnd"]];
    if (privacyBefore != nil) {
        tXCustomModel.privacyPreText = privacyBefore;
    }
    if (vendorPrivacySuffix != nil) {
        tXCustomModel.privacySufText = privacyEnd;
    }
    NSString *privacyBottomOffsetY = [config objectForKey:[self methodName2KeyName:@"setPrivacyBottomOffsetY"]];
    tXCustomModel.privacyFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat x = frame.origin.x;
        CGFloat y = frame.origin.y;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if (privacyBottomOffsetY != nil) {
            y = [privacyBottomOffsetY floatValue];
        }
        return CGRectMake(x, y, width, height);
    };

    NSString *checkboxHidden = [config objectForKey:[self methodName2KeyName:@"setCheckboxHidden"]];
    if (checkboxHidden != nil) {
        tXCustomModel.checkBoxIsHidden = [checkboxHidden boolValue];
    }

    NSString *alertBarHidden = [config objectForKey:[self methodName2KeyName:@"setAlertBarHidden"]];
    if (alertBarHidden != nil) {
        bool isHiddenAlertBar = [alertBarHidden boolValue];
        tXCustomModel.alertBarIsHidden = isHiddenAlertBar;
        if (isHiddenAlertBar) {
            //添加自定义控件并对自定义控件进行布局
            __block UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *alertBarCloseImgPath = [config objectForKey:[self methodName2KeyName:@"setAlertBarCloseImgPath"]];
            NSString *alertBarCloseImgWidth = [config objectForKey:[self methodName2KeyName:@"setAlertBarCloseImgWidth"]];
            NSString *alertBarCloseImgHeight = [config objectForKey:[self methodName2KeyName:@"setAlertBarCloseImgHeight"]];
            CGFloat closeWidth = 30;
            CGFloat closehHeight = 30;
            if (alertBarCloseImgWidth != nil) {
                closeWidth = [alertBarCloseImgWidth floatValue];
            }
            if (alertBarCloseImgHeight != nil) {
                closehHeight = [alertBarCloseImgHeight floatValue];
            }

            if (alertBarCloseImgPath != nil) {
                [customBtn setBackgroundImage:[UIImage imageNamed:alertBarCloseImgPath] forState:UIControlStateNormal];
            } else {
                [customBtn setTitle:@"关闭" forState:UIControlStateNormal];
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            customBtn.frame = CGRectMake(0, 0, closeWidth, closehHeight);
            [customBtn addTarget:self
                       action:@selector(btnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
            tXCustomModel.customViewBlock = ^(UIView * _Nonnull superCustomView) {
                 [superCustomView addSubview:customBtn];
            };
            tXCustomModel.customViewLayoutBlock = ^(CGSize screenSize, CGRect contentViewFrame, CGRect navFrame, CGRect titleBarFrame, CGRect logoFrame, CGRect sloganFrame, CGRect numberFrame, CGRect loginFrame, CGRect changeBtnFrame, CGRect privacyFrame) {
                CGRect frame = customBtn.frame;
                frame.origin.x = contentViewFrame.size.width - closeWidth; //screenSize.width - contentViewFrame.origin.x;
                CGFloat ts = screenSize.width - contentViewFrame.origin.x;
                frame.origin.y = CGRectGetMinY(navFrame);
//                frame.size.width = contentViewFrame.size.width - frame.origin.x * 2;
                customBtn.frame = frame;
            };
        } else {
            NSString *navColor = [config objectForKey:[self methodName2KeyName:@"setNavColor"]];
            NSString *navText = [config objectForKey:[self methodName2KeyName:@"setNavText"]];
            NSString *navTextColor = [config objectForKey:[self methodName2KeyName:@"setNavTextColor"]];
            NSString *navTextSize = [config objectForKey:[self methodName2KeyName:@"setNavTextSize"]];
            if (navText != nil) {
                tXCustomModel.alertTitle = [[NSAttributedString alloc]initWithString:navText attributes:@{NSForegroundColorAttributeName: [self colorWithHexString:navTextColor], NSFontAttributeName:[UIFont systemFontOfSize:[navTextSize doubleValue]]}];
            }
            NSString *navReturnImgPath = [config objectForKey:[self methodName2KeyName:@"setNavReturnImgPath"]];
            if (navReturnImgPath != nil) {
                tXCustomModel.alertCloseImage = [UIImage imageNamed:navReturnImgPath];
            }
        }

    }

    resolve(@"");
}

- (void)btnClick: (UIGestureRecognizer *) sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
    });
}

-(NSArray<NSString *> *)supportedEvents {
    return @[@"onTokenSuccess", @"onTokenFailed"];
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

/// 是否是横屏 YES:横屏 NO:竖屏
- (BOOL)isHorizontal:(CGSize)size {
    return size.width > size.height;
}

@end
