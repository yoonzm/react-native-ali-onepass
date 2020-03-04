//
//  ZOAuthManager 能力接入管理者-提供加解密方法
//  OAuthSDKApp
//
//  Created by zhangQY on 2019/5/13.
//  Copyright © 2019 com.zzx.sdk.ios.test. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZOAuthManager : NSObject

/**
 *  是否使用测试环境
 *
 *  @param isDebug true／false
 */
+ (void) setDebug:(Boolean) isDebug ;

//是否使用SHA256验签  默认NO
+ (void) useSchemeBInSecurityModule:(BOOL)schemeB;


@end
