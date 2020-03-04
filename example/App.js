/**
 * Created by lvshaoli on 2020/1/9.
 */
import React, {Component} from 'react';
import {
  Text,
  View,
  Button,
  StyleSheet,
  Platform,
  Dimensions
} from 'react-native';
import * as OnePass from 'react-native-ali-onepass';

// 比例 652 为设计稿高度
function getOffsetY(y) {
  return Math.floor(Dimensions.get('window').height * (y - 60) / 650)
}

export default class App extends Component {
  constructor() {
    super();
    this.state = {
      content: ''
    };
    this.listerens = [];
  }

  componentDidMount() {
    this.init();
    this.listerens = [
      OnePass.addListener(OnePass.EVENTS.onTokenSuccess, (data) => {
        this.insert(OnePass.EVENTS.onTokenSuccess, data);
        try {
          const {code} = JSON.parse(data.token);
          if (parseInt(code) === 600000) {
            OnePass.hideLoginLoading();
            OnePass.quitLoginPage();
          } else if (parseInt(code) === 600001) {

          }
        } catch (error) {
          console.error('捕获错误', error);
        }
      }),
      OnePass.addListener(OnePass.EVENTS.onTokenFailed, (data) => {
        this.insert(OnePass.EVENTS.onTokenFailed, data);
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

  init = async () => {
    try {
      await OnePass.init(Platform.OS === 'ios' ? "cf5091d791b9488aa6a91449fb398643" : "hwjOx8YurHPeQmB3/TeXDV/x4EQXvM9QToQMR8Rp/FCAq36nA8hNK6edLDa9H9O9OlhYOYyN1hr8J1pBsusudqLPXvGTeCMQk59fPZSlwIrSa7sQu3/CG5AyicyPaA1vEqbVk8N7y37tFUY3SZ1uIj1ExIgIQztpazgYKTuroi/23kVVXO44nmmRftNG5//Ut3QetIPa+2xDMl7Gkjw5jrUXjAt07gY7xKqhIYCeIOWVPZk8LH6ydx8bwDXNhshZcoLwrFuWxb7ht9o0vEHcJmyN9XFVCR69jRK/OF5pI9c=");
      this.insert('init');
      await OnePass.prefetch();
    } catch (error) {
      this.insert('error', error.message);
    }
  };

  onePass = async () => {
    const config = {
      //状态栏
      statusBarColor: '#FFFFFF',
      lightColor: true,
      statusBarHidden: false,
      // 标题栏
      navColor: '#FFFFFF',
      navTextColor: '#333333',
      navText: '登录',
      navTextSize: 18,
      webNavColor: '#FFFFFF',
      webNavTextColor: '#333333',
      webNavTextSize: 18,
      navReturnImgPath: 'back_icon',
      navReturnImgWidth: 20,
      navReturnImgHeight: 20,
      // logo
      logoImgPath: 'app_logo',
      logoHidden: false,
      logoWidth: 80,
      logoHeight: 80,
      logoOffsetY: getOffsetY(175),
      // 手机号掩码
      numFieldOffsetY: getOffsetY(300),
      // slogan
      sloganTextColor: '#B2B2B2',
      sloganTextSize: 13,
      sloganOffsetY: getOffsetY(384),
      // 登录按钮
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
      checkboxHidden: true,
      privacyState: true,
      appPrivacyOneName: '《智慧好医生APP协议》',
      appPrivacyOneUrl: 'https://www.baidu.com',
      vendorPrivacyPrefix: '《',
      vendorPrivacySuffix: '》',
      privacyTextSize: 12,
      appPrivacyBaseColor: '#B2B2B2',
      appPrivacyColor: '#0EA8FF',
    };
    console.log('App.onePass()', config);
    await OnePass.setUIConfig(config);
    this.insert('UI初始化完成');
    const operatorType = await OnePass.getOperatorType();
    this.insert('operatorType', operatorType);
    const {token, accessToken} = await OnePass.onePass();
    this.insert('token', token);
    this.insert('accessCode', accessToken);
  };

  render() {
    return (
      <View style={styles.container}>
        <Button title="一键登录" onPress={this.onePass}/>
        <Text>{this.state.content}</Text>
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
  }
});
