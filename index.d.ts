import { EmitterSubscription } from 'react-native';



export type UIConfig = {
  /** --start 仅限安卓 --- */
  lightColor?: boolean, // 状态栏亮色或暗色
  statusBarHidden?: true, // 状态栏显示与隐藏
  pageBackgroundPath?: string, // 背景图片地址
  /** --end 仅限安卓 --- */

  // nav相关
  navColor?: string, // nav颜色
  navTextColor?: string, // nav文字颜色
  navText?: string, // nav文字内容
  navTextSize?: number, // nav文字大小
  navHidden?: true, // nav显示与隐藏
 
  // 协议webview配置
  webNavColor?: string, // nav颜色
  webNavTextColor?: string, // nav文字颜色
  webNavTextSize?: number, // nav文字内容
  navReturnImgPath?: string, // 返回按钮图片地址

  // logo相关
  logoImgPath?: string,
  logoHidden?: boolean,
  logoWidth?: number,
  logoHeight?: number,
  logoOffsetY?: number, // logo 竖直方向位置


  // 手机号掩码
  numberColor?: string,
  numberSize?: number,

  // slogan相关
  sloganText?: string,
  sloganTextColor?: string,
  sloganTextSize?: number,
  sloganOffsetY?: number,

  // 登录按钮相关 
  logBtnText?: string,
  logBtnTextColor?: string,
  logBtnTextSize?: number,
  logBtnMarginLeftAndRight?: number, // 登录按钮左右margin

  // 登录按钮背景 ios
  logBtnBackgroundPaths?: string[],
  // 登录按钮背景 android
  logBtnBackgroundPath?: string,
  
  // 其他登录方式
  switchAccText?: string,
  switchAccTextSize?: number,
  switchAccTextColor?: string,

  // 协议栏
  privacyBefore?: string, // 协议前面的文字
  privacyEnd?: string, // 协议后面的文字
  vendorPrivacyPrefix?: string, // 运营商协议前面的文字
  vendorPrivacySuffix?: string, // 运营商协议后面的文字
  checkboxHidden?: boolean, // checkBox框的显示和隐藏
  privacyState?: boolean, // checkBox选中情况
  appPrivacyOneName?: string, // 自定义协议的名称
  appPrivacyOneUrl?: string, // 自定义协议的地址
  privacyTextSize?: number,
  appPrivacyBaseColor?: string,
  appPrivacyColor?: string,

    // 弹窗使用
  dialogHeightDelta?: number,
  alertBarHidden?: boolean,
  alertBarCloseImgPath?: string,
  alertBarCloseImgWidth?: number,
  alertBarCloseImgHeight?: number,
}; // 提示：安卓端图片需要放在 drawable 下，ios端图片需要放在 Images.xcassets 下


/**
 * 初始化
 * @param businessId 初始化密钥
 * @return {Promise<*>}
 */
export function init(businessId: string): Promise<any>;

/**
 * 调用下面接口前先校验是否支持
 * @return {Promise<*>}
 */
export function checkEnvAvailable(type: 1 | 2): Promise<any>;

/*******************************************(以下初始化后再调用)***********************************************/

/**
 * 预加载
 * @return {Promise<*>}
 */
export function prefetch(): Promise<any>;

/**
 * 一键登录
 * @return {Promise<*>}
 */
export function onePass(): Promise<any>;

/**
 * 判断运营商类型 中国移动 中国联通 中国电信
 * @return {Promise<string>} OPERATOR_TYPE
 */
export function getOperatorType(): Promise<string>;

/**
 * 退出登录授权⻚ , 授权⻚的退出完全由 APP  控制, 注意需要在主线程调用此函数    !!!!
 * @return {Promise<*>}
 */
export function quitLoginPage(): Promise<any>;

/**
 * 退出登录授权⻚时,授权⻚的 loading 消失由 APP 控制
 * @return {Promise<*>}
 */
export function hideLoginLoading(): Promise<any>;

/**
 * 设置授权页面UI
 * @param config
 */
export function setUIConfig(config: UIConfig): void;

export function setDialogUIConfig(config: UIConfig): void;

/**
 * 支持的监听事件
 * @type {{code, msg, requestCode, token, vendorName}}
 */
export const EVENTS: {
  onTokenSuccess: 'onTokenSuccess',
  onTokenFailed: 'onTokenFailed',
};

/**
 * 返回值code
 * @type {{"600000": number, "600001": number, "600002": number, "600004": number, "600005": number, "600007": number, "600008": number, "600009": number, "600010": number, "600011": number, "600012": number, "600013": number, "600014": number, "600015": number, "600017": number, "600021": number, "700000": number, "700001": number, "700002": number, "700003": number, "700004": number}}
 */
export const RESULT_CODES: {
  TOKENSUCCESS: '600000', // 获取 token 成功
  AUTHPAGESUCCESS: '600001', // 唤起授权⻚成功
  SWITCHAUTHWAY: '700001', // 用户点击切换按钮
  PTAVICY_CLICK: '700004', // 点击协议富文本文字事件
  DEVICE_SUPPORT: '600024', // 终端环境支持认证
  600024: '600024', // 终端环境支持认证
  600000: '600000', // 获取 token 成功
  600001: '600001', // 唤起授权⻚成功
  600002: '600002', // 唤起授权⻚失败
  600004: '600004', // 获取运营商配置信息失败
  600005: '600005', // 手机终端不安全
  600007: '600007', // 未检测到 sim 卡
  600008: '600008', // 蜂窝网络未开启
  600009: '600009', // 无法判断运营商
  600010: '600010', // 未知异常
  600011: '600011', // 获取 token 失败
  600012: '600012', // 预取号失败
  600013: '600013', // 运营商维护升级,该功能不可用
  600014: '600014', // 运营商维护升级,该功能已达最大调用次数
  600015: '600015', // 接口超时
  600017: '600017', // AppID 、 Appkey 解析失败
  600021: '600021', // 点击登录时检测到运营商已切换
  700000: '700000', // 点击返回,用户取消免密登录
  700001: '700001', // 点击切换按钮,用户取消免密登录
  700002: '700002', // 点击登录按钮事件
  700003: '700003', // 点击 check box 事件
  700004: '700004', // 点击协议富文本文字事件
};

/**
 * 添加事件监听
 * @param eventName 事件名
 * @param cb 回调函数
 * @return {*}
 */
export function addListener(eventName: string, cb: Function): EmitterSubscription;
