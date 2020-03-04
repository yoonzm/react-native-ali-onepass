//
//  NTESQuickLoginManager.h
//  NTESQuickPass
//
//  Created by Ke Xu on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "NTESQuickLoginCMModel.h"
#import "NTESQuickLoginCUModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @abstract   block
 *
 *  @说明        初始化结果的回调，返回preCheck的token信息
 */
typedef void(^NTESQLInitHandler)(NSDictionary * _Nullable params, BOOL success);

/**
 *  @abstract   block
 *
 *  @说明        运营商预取号结果的回调，包含预取号是否成功、脱敏手机号（仅电信返回脱敏手机号）、运营商结果码（请参照运营商文档中提供的错误码信息）和描述信息
 *              ⚠️ 联通预取号无法获取脱敏手机号，需调用pushAuthorizePage拉起授权页面显示
 */
typedef void(^NTESQLGetPhoneNumHandler)(NSDictionary *resultDic);

/**
 *  @abstract   block
 *
 *  @说明        运营商登录认证的回调，包含认证是否成功、accessToken、运营商结果码（请参照运营商文档中提供的错误码信息）和描述信息
 */
typedef void(^NTESQLAuthorizeHandler)(NSDictionary *resultDic);

@interface NTESQuickLoginManager : NSObject

/**
 *  @abstract   属性
 *
 *  @说明        设置运营商预取号和授权登录接口的超时时间，单位ms，默认为3000ms
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  @abstract   单例
 *
 *  @return     返回NTESQuickLoginManager对象
 */
+ (NTESQuickLoginManager *)sharedInstance;

/**
 *  @abstract   判断当前上网卡的网络环境和运营商是否可以一键登录（必须开启蜂窝流量，必须上网网卡为移动、电信、联通运营商）
 */
- (BOOL)shouldQuickLogin;

/**
 *  @abstract   获取当前上网卡的运营商，0:未知 1:电信 2.移动 3.联通
 */
- (NSInteger)getCarrier;

/**
 *  @abstract   初始化配置参数
 *
 *  @param      businessID          易盾分配的业务方ID
 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
 *  @param      initHandler         返回初始化结果
 *
 */
- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout completion:(NTESQLInitHandler)initHandler;

/**
 *  @abstract   初始化配置参数
 *
 *  @param      businessID          易盾分配的业务方ID
 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
 *  @param      configURL           preCheck接口的私有化url，若传nil或@""，默认使用@"https://ye.dun.163yun.com/v1/oneclick/preCheck"
 *  @param      extData             当设置configURL时，可以增加额外参数，接入方自行处理
 *  @param      initHandler         返回初始化结果
 *
 */
- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout configURL:(NSString * _Nullable)configURL extData:(NSString *  _Nullable)extData completion:(NTESQLInitHandler)initHandler;

/**
 *  @abstract   移动、联通、电信 - 预取号接口，请确保在初始化成功后再调用此方法
 *
 *  @param      phoneNumberHandler  返回预取号结果
 *
 */
- (void)getPhoneNumberCompletion:(NTESQLGetPhoneNumHandler)phoneNumberHandler;

/**
 *  @abstract   电信 - 授权登录（取号接口），⚠️注意：此方法不要嵌套在getPhoneNumberCompletion的回调使用
 *
 *  @param      authorizeHandler    登录授权结果回调
 */
- (void)CTAuthorizeLoginCompletion:(NTESQLAuthorizeHandler)authorizeHandler;

/**
 *  @abstract   设置移动授权登录界面model，⚠️注意：必须调用，此方法需嵌套在getPhoneNumberCompletion的回调中使用，且在authorizeLoginViewController:result:之前调用
 *
 *  @param      model   移动登录界面model，必传
 */
- (void)setupCMModel:(NTESQuickLoginCMModel *)model;

/**
 *  @abstract   设置联通授权登录界面model，⚠️注意：必须调用，此方法需嵌套在getPhoneNumberCompletion的回调中使用，且在authorizeLoginViewController:result:之前调用
 *
 *  @param      model   联通登录界面model，必传
 */
- (void)setupCUModel:(NTESQuickLoginCUModel *)model;

/**
 *  @abstract   联通、移动 - 授权登录（取号接口），⚠️注意：此方法需嵌套在getPhoneNumberCompletion的回调中使用，且在setupCMModel:或setupCUModel:之后调用
 *
 *  @param      authorizeHandler    登录授权结果回调，包含认证成功和认证失败，认证失败情况包括取号失败、用户取消登录（点按返回按钮）和切换登录方式，可根据code码做后续自定义操作
 *                                  取消登录:移动返回code码200020，联通返回10104
 *                                  切换登录方式:移动返回code码200060，联通返回10105
 */
- (void)CUCMAuthorizeLoginCompletion:(NTESQLAuthorizeHandler)authorizeHandler;

/**
 获取当前SDK版本号
 */
- (NSString *)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
