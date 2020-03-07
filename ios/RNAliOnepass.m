
#import "RNAliOnepass.h"

@implementation RNAliOnepass {
    TXCommonHandler *tXCommonHandler;
    NSInteger *prefetchNumberTimeout;
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
        if(resultCode==PNSCodeSuccess) {
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
    [tXCommonHandler checkEnvAvailableWithComplete:^(NSDictionary * _Nullable resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if(resultCode==PNSCodeSuccess) {
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
        if(resultCode==PNSCodeSuccess) {
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
    [tXCommonHandler getLoginTokenWithTimeout:0.0 controller:[UIApplication sharedApplication].keyWindow.rootViewController model:nil complete:^(NSDictionary * _Nonnull resultDic) {
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if(resultCode==PNSCodeSuccess) {
            // TODO TOKEN
            resolve(@"");
        } else if(([resultCode intValue] >= [PNSCodeLoginControllerPresentFailed intValue]) && ([resultCode intValue] <= [PNSCodeCarrierChanged intValue])) {
            reject(resultCode, [resultDic objectForKey:@"msg"], nil);
        }
    }];
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

-(NSArray<NSString *> *)supportedEvents {
    return @[];
}

@end
  
