import React, {Component} from 'react';
import {
  Text,
  View,
  Button,
  StyleSheet,
  Platform,
  Dimensions,
  Alert, ScrollView
} from 'react-native';
import * as OnePass from 'react-native-ali-onepass';
import OnepassKey from './config/onepass-key';

// 比例 652 为设计稿高度
function getOffsetY(y) {
  return Math.floor(Dimensions.get('window').height * (y - 60) / 650)
}

export default class App extends Component {
  constructor() {
    super();
    this.state = {
      content: '',
      initSuccess: false
    };
    this.listerens = [];
  }

  componentDidMount() {
    this.init();
    this.listerens = [
      OnePass.addListener(OnePass.EVENTS.onTokenSuccess, async (data) => {
        try {
          console.log('onTokenSuccess', data);
          const {code, msg, requestCode, token, vendorName} = data;
          const numberCode = Number(code);
          if (numberCode === OnePass.RESULT_CODES["600000"]) {
            this.insert('token', token);
            await OnePass.hideLoginLoading();
            await OnePass.quitLoginPage();
          } else if (numberCode === OnePass.RESULT_CODES["700001"]) {
            this.insert('token', msg);
            await OnePass.quitLoginPage();
          } else {
            this.insert('token', msg);
          }
        } catch (error) {
          console.error('捕获错误', error);
        }
      }),
      OnePass.addListener(OnePass.EVENTS.onTokenFailed, (data) => {
        try {
          console.log('onTokenFailed', data);
          const {code, msg, requestCode, token, vendorName} = data;
          Alert.alert('温馨提示', msg);
        } catch (error) {
          console.error('捕获错误', error);
        }
      })
    ]
  }

  componentWillUnmount() {
    this.listerens.forEach(item => item.remove());
  }

  insert(key, value) {
    console.log('quickpass.insert()', {
      key, value
    });
    this.setState({
      content: this.state.content + '\n' + `${key}:${value}`
    })
  }

  get key() {
    if (Platform.OS === 'ios') {
      return OnepassKey.ios
    }
    return __DEV__ ? OnepassKey.android : OnepassKey.androidRelease
  }

  init = async () => {
    try {
      await OnePass.init(this.key);
      this.insert('init', '初始化成功');
      this.setState({
        initSuccess: true
      });
      const available = await OnePass.checkEnvAvailable();
      this.insert('checkEnvAvailable', available + "");
      await OnePass.prefetch();
      this.insert('prefetch', "");
    } catch (error) {
      this.insert('error', error.message);
    }
  };

  onePass = async () => {
    const operatorType = await OnePass.getOperatorType();
    this.insert('operatorType', operatorType);
    const config = {
      //状态栏
      statusBarColor: '#FFFFFF',
      lightColor: true,
      statusBarHidden: false,
      // 弹窗使用
      dialogHeightDelta: 100,
      alertBarHidden: true,
      alertBarCloseImgPath: 'onepass_close_btn',
      alertBarCloseImgWidth: 30,
      alertBarCloseImgHeight : 30,
      privacyBottomOffetY:getOffsetY(325),
      // 标题栏
      navColor: '#FFFFFF',
      navTextColor: '#333333',
      navText: '登录',
      navTextSize: 18,
      webNavColor: '#FFFFFF',
      webNavTextColor: '#333333',
      webNavTextSize: 18,
      navReturnImgPath: 'back_icon',
      // navReturnImgWidth: 48,
      // navReturnImgHeight: 48,
      // logo
      logoImgPath: 'app_logo',
      logoHidden: false,
      logoWidth: 80,
      logoHeight: 80,
      logoOffsetY: getOffsetY(175),
      // 手机号掩码
      numberColor: '#333333',
      numberSize: 25,
      numberFieldOffsetY: getOffsetY(300),
      // slogan
      sloganText: `${operatorType}提供认证服务`,
      sloganTextColor: '#B2B2B2',
      sloganTextSize: 13,
      sloganOffsetY: getOffsetY(384),
      // 登录按钮
      logBtnText: '本机号码一键登录',
      logBtnTextColor: '#FFFFFF',
      logBtnTextSize: 18,
      // ios
      logBtnBackgroundPaths: ['onepass_login_btn_normal', 'onepass_login_btn_press', 'onepass_login_btn_unable'],
      // android
      logBtnBackgroundPath: 'login_btn_bg',
      logBtnMarginLeftAndRight: 35,
      logBtnOffsetY: getOffsetY(417),
      // 其他登录方式
      switchAccText: '其他登录方式',
      switchAccTextSize: 15,
      switchAccTextColor: '#0EA8FF',
      switchOffsetY: getOffsetY(492),
      // 协议栏
      privacyBefore: '登录即同意',
      privacyEnd: '并授权获取本机号码',
      checkboxHidden: true,
      privacyState: true,
      appPrivacyOneName: '《xxx APP协议》',
      appPrivacyOneUrl: 'https://www.baidu.com',
      vendorPrivacyPrefix: '《',
      vendorPrivacySuffix: '》',
      privacyTextSize: 12,
      appPrivacyBaseColor: '#B2B2B2',
      appPrivacyColor: '#0EA8FF',
    };
    console.log('App.onePass()', config);
    await OnePass.setUIConfig(config);
    this.insert('UI初始化完成', "");
    await OnePass.onePass();
  };

  render() {
    return (
      <View style={styles.container}>
        <Button disabled={!this.state.initSuccess} title="一键登录" onPress={this.onePass}/>
        <View style={{height: 20}}/>
        <ScrollView>
          {this.state.content.split('\n').map((item, index) => (
            <Text key={index} style={{
              lineHeight: 25,
              color: '#333'
            }} selectable>{item}</Text>
          ))}
        </ScrollView>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
    paddingVertical: 20,
    paddingHorizontal: 15
  }
});
