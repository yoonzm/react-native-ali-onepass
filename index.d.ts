declare module 'react-native-ali-onepass' {
  export interface Listener {
    remove: () => void;
  }

  export function init(businessId: string): Promise<any>;
  export function checkEnvAvailable(): Promise<any>;
  export function prefetch(): Promise<any>;
  export function onePass(): Promise<any>;
  export function getOperatorType(): Promise<string>;
  export function quitLoginPage(): Promise<any>;
  export function hideLoginLoading(): Promise<any>;
  export function setUIConfig(config: any): Promise<any>;
  export function setDialogUIConfig(config: any): Promise<any>;
  export function addListener(
    eventName: string,
    cb: (...args: any) => void
  ): Listener;

  export const EVENTS: {
    onTokenSuccess: string;
    onTokenFailed: string;
  };

  export const RESULT_CODES: {
    600000: 600000; // 获取 token 成功
    600001: 600001; // 唤起授权⻚成功
    600002: 600002; // 唤起授权⻚失败
    600004: 600004; // 获取运营商配置信息失败
    600005: 600005; // 手机终端不安全
    600007: 600007; // 未检测到 sim 卡
    600008: 600008; // 蜂窝网络未开启
    600009: 600009; // 无法判断运营商
    600010: 600010; // 未知异常
    600011: 600011; // 获取 token 失败
    600012: 600012; // 预取号失败
    600013: 600013; // 运营商维护升级,该功能不可用
    600014: 600014; // 运营商维护升级,该功能已达最大调用次数
    600015: 600015; // 接口超时
    600017: 600017; // AppID 、 Appkey 解析失败
    600021: 600021; // 点击登录时检测到运营商已切换
    700000: 700000; // 点击返回,用户取消免密登录
    700001: 700001; // 点击切换按钮,用户取消免密登录
    700002: 700002; // 点击登录按钮事件
    700003: 700003; // 点击 check box 事件
    700004: 700004; // 点击协议富文本文字事件
  };
}
