
import { NativeModules, Platform, NativeEventEmitter } from 'react-native';

const { RNAliOnepass } = NativeModules;
const eventEmitter = new NativeEventEmitter(RNAliOnepass);

export async function init(businessId) {
  return await RNAliOnepass.init(businessId);
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
 * 运营商类型
 * @type {{cm: string, cu: string, ct: string, wifi: string, unknown: string}}
 */
export const OPERATOR_TYPE = {
  cm: '移动',
  cu: '联通',
  ct: '电信',
  wifi: 'wifi',
  unknown: '未知',
};

/**
 * 判断运营商类型
 * @return {Promise<string>} OPERATOR_TYPE
 */
export async function getOperatorType() {
  return await RNAliOnepass.getOperatorType();
}

/**
 * 设置预取号超时时间，单位s
 * @param timeout
 * @return {Promise<*>}
 */
export async function setPrefetchNumberTimeout(timeout) {
  return await RNAliOnepass.setPrefetchNumberTimeout(timeout);
}

/**
 * 设置取号超时时间，单位s
 * @param timeout
 * @return {Promise<*>}
 */
export async function setFetchNumberTimeout(timeout) {
  return await RNAliOnepass.setFetchNumberTimeout(timeout);
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

/**
 * 支持的监听事件
 * @type {{}}
 */
export const EVENTS = {
  onTokenSuccess: 'onTokenSuccess',
  onTokenFailed: 'onTokenFailed',
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
