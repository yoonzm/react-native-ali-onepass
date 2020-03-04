//
//  ZUOAuthManager 联通能力接入管理者
//  OAuthSDKApp
//
//  Created by zhangQY on 2019/5/13.
//  Copyright © 2019 com.zzx.sdk.ios.test. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZOAUResultListener.h"
#import "ZOAUCustomModel.h"
#import "ZOAuthManager.h"

@interface ZUOAuthManager : ZOAuthManager


/**
 *  获取联通能力接入单例对象
 */
+ (instancetype)getInstance;


/**
 *  初始化-联通
 */
- (void) init:(NSString*) apiKey pubKey:(NSString*)pubKey;


/**
 *  预取号-联通
 */
- (void) loginPre:(double)timeout resultListener:(resultListener)listener;


/**
 * 登录-联通
 */
- (void) login:(UIViewController*)uiController timeout:(double)timeout resultListener:(resultListener)listener;


/**
 中断取号登录流程
 1.取消取号请求
 2.如果已经拉起授权页时，取消授权页显示
 @param tryToCancelRequest 尝试取消取号请求
 @param ifDisappear 是否强制收起可能已经拉起的授权页
 @param ifCancel 和tryToCancelRequest 一起使用 是否取消最近的一次拉起授权页/取消本次登录流程的授权页拉起
 eg:只取消网络请求 [Who interruptTheCULoginFlowANDIfDisapperTheShowingLoginPage:NO cancelTheNextAuthorizationPageToPullUp:NO];
 */
- (void)interruptTheCULoginFlow:(BOOL)tryToCancelRequest ifDisapperTheShowingLoginPage:(BOOL)ifDisappear  cancelTheNextAuthorizationPageToPullUp:(BOOL)ifCancel;


/**
 *  认证-联通
 注意***：在不手动关闭缓存的时，请及时调用清除缓存方法
 */
- (void) oauth:(double)timeout resultListener:(resultListener)listener;


/** 联通认证：是否关闭缓存策略（默认开启）
 请注意及时调用clearOauthCache方法清除缓存；
 手动关闭后，不必调用clearOauthCache；
 @param  yesOrNo 是否关闭联通认证缓存策略
 */
- (void) closeCUOauthCachingStrategy:(BOOL)yesOrNo;


/**
 联通认证：
 清除联通认证缓存策略中产生的缓存数据；
 在手动关闭缓存策略时，不必调用；
 */
- (BOOL) clearCUOauthCache;


/**
 *  获取登录/认证结果
 *  测试接口
 */
- (void) gmbc:(NSString*)accessCode mobile:(NSString *)mobile listener:(resultListener)listener;


- (void) gmbc:(NSString*)accessCode listener:(resultListener)listener;

//修改UI
-(void) customUIWithParams:(ZOAUCustomModel *)customUIParams topCustomViews:(void(^)(UIView *customView))topCustomViews bottomCustomViews:(void(^)(UIView *customView))bottomCustomViews;


//自定义跳转
-(void)setLoginSuccessPage:(UIViewController *)uiController;


//释放SDK内部单例对象（免密登录：授权页销毁时自动释放；认证：获取到授权码后自动释放）
-(void)ZOAURelease;

@end
