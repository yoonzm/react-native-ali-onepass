//
//  UACustomModel.h
//  Test
//
//  Created by issuser on 2018/5/18.
//  Copyright © 2018年 林涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UAPresentationDirection){
    UAPresentationDirectionBottom = 0,  //底部  present默认效果
    UAPresentationDirectionRight,       //右边  导航栏效果
    UAPresentationDirectionTop,         //上面
    UAPresentationDirectionLeft,        //左边
};

@interface UACustomModel : NSObject

/**
 版本注意事项:
 授权页面的各个控件的Y轴默认值都是以375*667屏幕为基准 系数 ： 当前屏幕高度/667
 1、当设置Y轴并有效时 偏移量OffsetY属于相对导航栏的绝对Y值
 2、（负数且超出当前屏幕无效）为保证各个屏幕适配,请自行设置好Y轴在屏幕上的比例（推荐:当前屏幕高度/667）
 */

#pragma mark -----------------------------授权页面----------------------------------

#pragma mark VC必传属性
/**1、当前VC,注意:要用一键登录这个值必传*/
@property (nonatomic,weak) UIViewController *currentVC;

#pragma mark 自定义控件
/**2、授权界面自定义控件View的Block*/
@property (nonatomic,copy) void(^authViewBlock)(UIView *customView ,CGRect logoFrame, CGRect numberFrame, CGRect sloganFrame ,CGRect loginBtnFrame, CGRect checkBoxFrame , CGRect privacyFrame);
/**3、 授权页面推出的动画效果：参考UAPresentationDirection枚举*/
@property (nonatomic, assign) UAPresentationDirection presentType;
/**4、授权界面背景图片*/
@property (nonatomic,strong) UIImage *authPageBackgroundImage;

#pragma mark 导航栏
/**5、导航栏颜色*/
@property (nonatomic,strong) UIColor *navColor;
/**6、状态栏着色样式(隐藏导航栏无效)*/
@property (nonatomic,assign) UIBarStyle barStyle;
/**7、状态栏着色样式(隐藏导航栏时设置)*/
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
/**8、导航栏标题*/
@property (nonatomic,strong) NSAttributedString *navText;
/**9、导航返回图标(尺寸根据图片大小)*/
@property (nonatomic,strong) UIImage *navReturnImg;
/**10、导航栏自定义（适配全屏图片）*/
@property (nonatomic,assign) BOOL navCustom;
/**11、导航栏右侧自定义控件（导航栏传 UIBarButtonItem对象 自定义传非UIBarButtonItem ）*/
@property (nonatomic,strong) id navControl;

#pragma mark LOGO图片设置
/**12、LOGO图片*/
@property (nonatomic,strong) UIImage *logoImg;
/**13、LOGO图片宽度*/
@property (nonatomic,assign) CGFloat logoWidth;
/**14、LOGO图片高度*/
@property (nonatomic,assign) CGFloat logoHeight;
/**15、LOGO图片偏移量*/
@property (nonatomic,strong) NSNumber * logoOffsetY;
/**16、LOGO图片隐藏*/
@property (nonatomic,assign) BOOL logoHidden;

#pragma mark 登录按钮
/**17、登录按钮文本*/
@property (nonatomic,strong) NSAttributedString *logBtnText;
/**18、登录按钮Y偏移量*/
@property (nonatomic,strong) NSNumber * logBtnOffsetY;
/**19、登录按钮的左右边距 注意:按钮呈现的宽必须大于屏幕的一半*/
@property (nonatomic, strong) NSNumber *logBtnOriginX;
/**20、登录按钮高h 注意：必须大于40*/
@property (nonatomic, assign) CGFloat logBtnHeight;
/**21、登录按钮背景图片添加到数组(顺序如下)
 @[激活状态的图片,失效状态的图片,高亮状态的图片]
*/
@property (nonatomic,strong) NSArray *logBtnImgs;

#pragma mark 号码框设置
/**22、手机号码（内容设置无效）*/
@property (nonatomic,strong) NSAttributedString *numberText;
/**23、号码栏X偏移量*/
@property (nonatomic,strong) NSNumber * numberOffsetX;
/**24、号码栏Y偏移量*/
@property (nonatomic,strong) NSNumber * numberOffsetY;

#pragma mark 切换账号
/**25、隐藏切换账号按钮*/
@property (nonatomic,assign) BOOL swithAccHidden;
/**26、切换账号*/
@property (nonatomic,strong) NSAttributedString *switchAccText;
/**27、设置切换账号相对于标题栏下边缘y偏移*/
@property (nonatomic,strong) NSNumber *switchOffsetY;

#pragma mark 隐私条款
/**28、复选框未选中时图片*/
@property (nonatomic,strong) UIImage *uncheckedImg;
/**29、复选框选中时图片*/
@property (nonatomic,strong) UIImage *checkedImg;
/**30、复选框大小（只能正方形）必须大于12*/
@property (nonatomic,assign) NSNumber *checkboxWH;
/**31、隐私条款（包括check框）的左右边距*/
@property (nonatomic, strong) NSNumber *appPrivacyOriginX;
/**32、隐私的内容模板：
 1、全句可自定义但必须保留"&&默认&&"字段表明SDK默认协议,否则设置不生效
 2、协议1和协议2的名称要与数组 str1 和 str2 ... 里的名称 一样
 3、必设置项（参考SDK的demo）
 appPrivacieDemo设置内容：登录并同意&&默认&&和&&百度协议&&、&&京东协议2&&登录并支持一键登录
 展示：   登录并同意中国移动条款协议和百度协议1、京东协议2登录并支持一键登录
 */
@property (nonatomic, copy) NSAttributedString *appPrivacyDemo;
/**33、隐私条款文字内容的方向:默认是居左
 */
@property (nonatomic,assign) NSTextAlignment appPrivacyAlignment;
/**34、隐私条款:数组（务必按顺序）要设置NSLinkAttributeName属性可以跳转协议
 对象举例：
 NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:@"百度协议" attributes:@{NSLinkAttributeName:@"https://www.baidu.com"}];
 @[str1,,str2,str3,...]
 */
@property (nonatomic,strong) NSArray <NSAttributedString *> *appPrivacy;
/**35、隐私条款名称颜色（协议）统一设置
 */
@property (nonatomic,strong) UIColor *privacyColor;
/**36、隐私条款Y偏移量(注:此属性为与屏幕底部的距离)*/
@property (nonatomic,strong) NSNumber * privacyOffsetY;
/**37、隐私条款check框默认状态 默认:NO */
@property (nonatomic,assign) BOOL privacyState;

/**38、隐私条款默认协议是否开启书名号
 */
@property (nonatomic, assign) BOOL privacySymbol;

#pragma mark 底部标识Title
/**39、slogan偏移量Y*/
@property (nonatomic,strong) NSNumber * sloganOffsetY;
/**40、slogan文字S*/
@property (nonatomic,strong) NSAttributedString *sloganText;

#pragma mark -----------------------------------短信页面-----------------------------------

/**41、SDK短信验证码开关
 （默认为NO,不使用SDK提供的短验直接回调 ,YES:使用SDK提供的短验）
 为NO时,授权界面的切换账号按钮直接返回字典:200060 和 导航栏 “NavigationController”*/
@property (nonatomic,assign) BOOL SMSAuthOn;
/**42、短验页面导航栏标题*/
@property (nonatomic,strong) NSAttributedString *SMSNavText;
/**43、登录按钮文本内容*/
@property (nonatomic,strong) NSAttributedString *SMSLogBtnText;
/**44、短验登录按钮图片请按顺序添加到数组(顺序如下)
 @[激活状态的图片,失效状态的图片,高亮状态的图片]
 */
@property (nonatomic,strong) NSArray *SMSLogBtnImgs;
/**45、获取验证码按钮图片请按顺序添加到数组(顺序如下)
 @[激活状态的图片,失效状态的图片]
 */
@property (nonatomic,strong) NSArray *SMSGetCodeBtnImgs;
/**46、短验界面背景*/
@property (nonatomic,strong) UIImage *SMSBackgroundImage;

#pragma mark -----------------------------------协议页面-----------------------------------
/**47、web协议界面导航返回图标(尺寸根据图片大小)*/
@property (nonatomic,strong) UIImage *webNavReturnImg;

#pragma mark ----------------------弹窗:(温馨提示:由于受屏幕影响，小屏幕（5S,5E,5）需要改动字体和另自适应和布局)--------------------
#pragma mark --------------------------窗口模式1（居中弹窗） 弹框模式需要配合自定义坐标属性使用可自适应-----------------------------------

//务必在设置控件位置时，自行查看各个机型模拟器是否正常
/**温馨提示:
 窗口1模式下，自动隐藏系统导航栏,并生成一个UILabel 其frame为（0,0,窗口宽*scaleW,44*scaleW）
 返回按钮的frame查看51属性备注,添加在UILabel的center.y位置
*/
/**48、窗口模式开关*/
@property (nonatomic,assign) BOOL authWindow;

/**49、窗口模式推出动画
 UIModalTransitionStyleCoverVertical, 下推
 UIModalTransitionStyleFlipHorizontal,翻转
 UIModalTransitionStyleCrossDissolve, 淡出
 */
@property (nonatomic,assign) UIModalTransitionStyle modalTransitionStyle;

/**50、自定义窗口弧度 默认是10*/
@property (nonatomic,assign) CGFloat cornerRadius;

/**51、自定义窗口宽-缩放系数(屏幕宽乘以系数) 默认是0.8*/
@property (nonatomic,assign) CGFloat scaleW;

/**52、自定义窗口高-缩放系数(屏幕高乘以系数) 默认是0.5*/
@property (nonatomic,assign) CGFloat scaleH;

/**53、返回按钮x偏移(负数左边偏移,正数右边偏移) 只有隐藏导航栏时有效 默认frame为 (20,居中,20 * 系数scaleW,20 * scaleW) */
@property (nonatomic,assign) CGRect navReturnImgFrame;

#pragma mark -----------窗口模式2（边缘弹窗） UIPresentationController（可配合UAPresentationDirection动画使用）-----------
/**54、此属性支持半弹框方式与authWindow不同（此方式为UIPresentationController）设置后自动隐藏切换按钮*/
@property (nonatomic,assign) CGSize controllerSize;

/**55、授权界面支持的方向,横屏;竖屏*/
@property (nonatomic, assign) UIInterfaceOrientation faceOrientation;

@end
