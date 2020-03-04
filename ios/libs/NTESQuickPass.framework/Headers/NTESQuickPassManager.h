//
//  NTESQuickPassManager.h
//  NTESQuickPass
//
//  Created by Xu Ke on 2018/4/10.
//

#import <Foundation/Foundation.h>

/**
 *  @abstract    获取accessToken的状态
 *
 *  @说明         NTESQPCompletionHandler对象的参数，用于表示获取accessToken的状态
 *               NTESQPPhoneNumInvalid表示手机号不合法
 *               NTESQPNonGateway表示当前网络环境不可网关验证
 *               NTESQPAccessTokenSuccess获取accessToken成功
 *               NTESQPAccessTokenFailure获取accessToken失败
 *               NTESQPAccessTokenTimeout获取accessToken超时
 *
 */
typedef NS_ENUM(NSInteger, NTESQPStatus) {
    NTESQPPhoneNumInvalid = 1,
    NTESQPNonGateway,
    NTESQPAccessTokenSuccess,
    NTESQPAccessTokenFailure,
    NTESQPAccessTokenTimeout,
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  @abstract   block
 *
 *  @说明        获取accessToken结果的回调
 */
typedef void(^NTESQPCompletionHandler)(NSDictionary * _Nullable params, NTESQPStatus status, BOOL success);

@interface NTESQuickPassManager : NSObject

/**
 *  @abstract   属性
 *
 *  @说明        设置获取accessToken的超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
 */
@property (nonatomic, assign) NSTimeInterval timeOut;

/**
 *  @abstract   单例
 *
 *  @return     返回NTESQuickPassManager对象
 */
+ (NTESQuickPassManager *)sharedInstance;

/**
 *  @abstract   配置参数
 *
 *  @param      phoneNumber         用户输入的手机号
 *  @param      businessID          易盾分配的业务方ID
 *  @param      completionHandler   返回验证结果，做下一步处理
 *
 */
- (void)verifyPhoneNumber:(NSString *)phoneNumber businessID:(NSString *)businessID completion:(NTESQPCompletionHandler _Nullable)completionHandler;

/**
 *  @abstract   配置参数
 *
 *  @param      phoneNumber         用户输入的手机号
 *  @param      businessID          易盾分配的业务方ID
 *  @param      configURL           preCheck接口的私有化url，若传nil或@""，默认使用@"https://ye.dun.163yun.com/v1/preCheck"
 *  @param      extData             当设置configURL时，可以增加额外参数，接入方自行处理
 *  @param      completionHandler   返回验证结果，做下一步处理
 *
 */
- (void)verifyPhoneNumber:(NSString *)phoneNumber businessID:(NSString *)businessID configURL:(NSString * _Nullable)configURL extData:(NSString *  _Nullable)extData completion:(NTESQPCompletionHandler _Nullable)completionHandler;

/**
 获取当前SDK版本号
 */
- (NSString *)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
