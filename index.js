import {NativeModules, Platform, NativeEventEmitter} from 'react-native';

const {RNAliOnepass} = NativeModules;
const eventEmitter = new NativeEventEmitter(RNAliOnepass);

export async function init(businessId) {
  return await RNAliOnepass.init(businessId);
}

/**
 * 调用下面接口前先校验是否支持
 * @return {Promise<*>}
 */
export async function checkEnvAvailable() {
  return await RNAliOnepass.checkEnvAvailable();
}

/*******************************************(以下初始化后再调用)***********************************************/

/**
 * 预加载
 * @return {Promise<*>}
 */
export async function prefetch() {
  return await RNAliOnepass.prefetch();
}

/**
 * 一键登录
 * @return {Promise<*>}
 */
export async function onePass() {
  return await RNAliOnepass.onePass();
}

/**
 * 判断运营商类型 中国移动 中国联通 中国电信
 * @return {Promise<string>} OPERATOR_TYPE
 */
export async function getOperatorType() {
  return await RNAliOnepass.getOperatorType();
}

/**
 * 退出登录授权⻚ , 授权⻚的退出完全由 APP  控制, 注意需要在主线程调用此函数    !!!!
 * @return {Promise<*>}
 */
export async function quitLoginPage() {
  return await RNAliOnepass.quitLoginPage();
}

/**
 * 退出登录授权⻚时,授权⻚的 loading 消失由 APP 控制
 * @return {Promise<*>}
 */
export async function hideLoginLoading() {
  return await RNAliOnepass.hideLoginLoading();
}

/**
 * setUIConfig
 * @param config
 */
export async function setUIConfig(config) {
  return await RNAliOnepass.setUIConfig(config);
}

export async function setDialogUIConfig(config) {
  return await RNAliOnepass.setDialogUIConfig(config);
}

/**
 * 支持的监听事件
 * @type {{code, msg, requestCode, token, vendorName}}
 */
export const EVENTS = {
  onTokenSuccess: 'onTokenSuccess',
  onTokenFailed: 'onTokenFailed',
};

/**
 * 返回值code
 * @type {{"600000": number, "600001": number, "600002": number, "600004": number, "600005": number, "600007": number, "600008": number, "600009": number, "600010": number, "600011": number, "600012": number, "600013": number, "600014": number, "600015": number, "600017": number, "600021": number, "700000": number, "700001": number, "700002": number, "700003": number, "700004": number}}
 */
export const RESULT_CODES = {
  600000: 600000, // 获取 token 成功
  600001: 600001, // 唤起授权⻚成功
  600002: 600002, // 唤起授权⻚失败
  600004: 600004, // 获取运营商配置信息失败
  600005: 600005, // 手机终端不安全
  600007: 600007, // 未检测到 sim 卡
  600008: 600008, // 蜂窝网络未开启
  600009: 600009, // 无法判断运营商
  600010: 600010, // 未知异常
  600011: 600011, // 获取 token 失败
  600012: 600012, // 预取号失败
  600013: 600013, // 运营商维护升级,该功能不可用
  600014: 600014, // 运营商维护升级,该功能已达最大调用次数
  600015: 600015, // 接口超时
  600017: 600017, // AppID 、 Appkey 解析失败
  600021: 600021, // 点击登录时检测到运营商已切换
  700000: 700000, // 点击返回,用户取消免密登录
  700001: 700001, // 点击切换按钮,用户取消免密登录
  700002: 700002, // 点击登录按钮事件
  700003: 700003, // 点击 check box 事件
  700004: 700004, // 点击协议富文本文字事件
};

/**
 * 添加事件监听
 * @param eventName
 * @param cb
 * @return {*}
 */
export function addListener(eventName, cb) {
  return eventEmitter.addListener(eventName, cb);
}
