//
//  EAccountSDK.h
//  EAccountSDKNetwork
//
//  Created by thy on 2018/6/23.
//  Copyright © 2018年 21CN. All rights reserved.
//

/**
 V 3.6.1 20190929
 */

#import <Foundation/Foundation.h>

/**
 声明一个block
 @param resultDic 网络返回的data的解析结果
 */
typedef   void (^successHandler) ( NSDictionary * _Nonnull resultDic);

/**
 声明一个block
 @param error 网络返回的错误或者其它错误
 */
typedef   void (^failureHandler) (NSError * _Nonnull error);

@interface EAccountSDK : NSObject

/**
 初始化SDK
 @param appKey 接入方在账号平台领取的appId
 @param appSecrect 接入方在账号平台领取的appSecrect
 */
+ (void)initWithSelfKey:(NSString * _Nonnull)appKey
              appSecret:(NSString * _Nonnull)appSecrect;


/**
 默认为正式环境的bundleID,需要使用测试环境的bundleID（企业证书重签名），请添加这个方法，在发布APP的时候请确保没有使用该方法。
 */

+(void)setTestBundleId;


/**
 *@description 预登录接口
 @param apiTimeoutInterval 接口超时时间，传0或者小于0的数，则默认为3s
 */

+ (void)requestPreLogin:(NSTimeInterval)apiTimeoutInterval
                      completion:(nonnull successHandler)completion
                         failure:(nonnull failureHandler)fail;


/**
 *@description 预登录接口 废弃
 @param apiTimeoutInterval 接口超时时间，传0或者小于0的数，则默认为3s
 */

+ (void)getMobileCodeWithTimeout:(NSTimeInterval)apiTimeoutInterval
                      completion:(nonnull successHandler)completion
                         failure:(nonnull failureHandler)fail  DEPRECATED_MSG_ATTRIBUTE("Method deprecated. Use `requestPreLogin:completion:failure:`");


@end
