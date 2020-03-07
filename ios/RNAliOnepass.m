
#import "RNAliOnepass.h"
//#import ""

@implementation RNAliOnepass {
    TXCommonHandler *tXCommonHandler;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(NSString *)secretInfo resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    tXCommonHandler = [TXCommonHandler sharedInstance];
    [tXCommonHandler setAuthSDKInfo:secretInfo complete:^(NSDictionary * _Nullable params, BOOL success) {
        if(success) {
            
        } else {
            reject(0, @"初始化失败", nil);
        }
    }];
}

@end
  
