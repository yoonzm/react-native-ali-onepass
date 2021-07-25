
package com.ali.onepass;

import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;
import android.widget.ImageView;

import com.alibaba.fastjson.JSON;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.mobile.auth.gatewayauth.AuthUIConfig;
import com.mobile.auth.gatewayauth.PhoneNumberAuthHelper;
import com.mobile.auth.gatewayauth.PreLoginResultListener;
import com.mobile.auth.gatewayauth.TokenResultListener;
import com.mobile.auth.gatewayauth.model.TokenRet;

import static com.ali.onepass.AppUtils.dp2px;

public class RNAliOnepassModule extends ReactContextBaseJavaModule implements TokenResultListener {
    static Promise COMMON_PROMISE = null;
    private final ReactApplicationContext reactContext;
    private PhoneNumberAuthHelper phoneNumberAuthHelper;
    private int prefetchNumberTimeout = 3000;
    private int fetchNumberTimeout = 3000;
    private int mScreenWidthDp;
    private int mScreenHeightDp;

    public RNAliOnepassModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNAliOnepass";
    }

    /**
     * 设置 sdk 秘钥信息
     *
     * @param secretInfo 方案对应的秘钥,请登录阿里云控制台后,进入认证方案管理,点击秘钥后复制秘钥,建议维护在业务服 务端
     * @param promise
     */
    @ReactMethod
    public void init(final String secretInfo, final Promise promise) {
        phoneNumberAuthHelper = PhoneNumberAuthHelper.getInstance(reactContext, this);
        phoneNumberAuthHelper.setAuthSDKInfo(secretInfo);
        promise.resolve("");
    }

    private boolean checkInit(final Promise promise) {
        if (phoneNumberAuthHelper != null) {
            return true;
        }
        promise.reject("0", "请先调用初始化接口init");
        return false;
    }

    /**
     * SDK 环境检查函数,检查终端是否支持号码认证
     */
    @ReactMethod
    public void checkEnvAvailable(final int type, final Promise promise)  {
      if (!checkInit(promise)) {
        return;
      }
      try {
          COMMON_PROMISE = promise;
          phoneNumberAuthHelper.checkEnvAvailable(type);

      } catch (Exception e) {
          promise.reject("-1" ,e.toString());
      }
    }

    @Override
    public void onTokenSuccess(String s) {

        WritableMap writableMap = Arguments.createMap();
        TokenRet tokenRet = null;
        try {
            tokenRet = JSON.parseObject(s, TokenRet.class);
            writableMap.putString("vendorName", tokenRet.getVendorName());
            writableMap.putString("code", tokenRet.getCode());
            writableMap.putString("msg", tokenRet.getMsg());
            writableMap.putInt("requestCode", tokenRet.getRequestCode());
            writableMap.putString("token", tokenRet.getToken());
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (COMMON_PROMISE != null) {
          COMMON_PROMISE.resolve(writableMap);
          COMMON_PROMISE = null;
        } else {
          sendEvent("onTokenSuccess", writableMap);
        }
        
    }

    @Override
    public void onTokenFailed(String s) {

        WritableMap writableMap = Arguments.createMap();
        TokenRet tokenRet = null;
        try {
            tokenRet = JSON.parseObject(s, TokenRet.class);
            writableMap.putString("vendorName", tokenRet.getVendorName());
            writableMap.putString("code", tokenRet.getCode());
            writableMap.putString("msg", tokenRet.getMsg());
            writableMap.putInt("requestCode", tokenRet.getRequestCode());
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (COMMON_PROMISE != null) {
          COMMON_PROMISE.resolve(writableMap);
          COMMON_PROMISE = null;
        } else {
          sendEvent("onTokenFailed", writableMap);
        }
        
    }

    /**
     * 预加载
     *
     * @param promise
     */
    @ReactMethod
    public void prefetch(final Promise promise) {
        if (!checkInit(promise)) {
            return;
        }
        phoneNumberAuthHelper.accelerateLoginPage(prefetchNumberTimeout, new PreLoginResultListener() {
            @Override
            public void onTokenSuccess(String s) {
                promise.resolve(s);
            }

            @Override
            public void onTokenFailed(String s, String s1) {
                promise.reject(s, s1);
            }
        });
    }

    /**
     * 一键登录
     *
     * @param promise
     */
    @ReactMethod
    public void onePass(final Promise promise) {
        if (!checkInit(promise)) {
            return;
        }
        phoneNumberAuthHelper.getLoginToken(reactContext, fetchNumberTimeout);
    }

    /**
     * 退出登录授权⻚ , 授权⻚的退出完全由 APP  控制, 注意需要在主线程调用此函数    !!!!
     * SDK  完成回调后,不会立即关闭授权⻚面,需要开发者主动调用离开授权⻚面方法去完成⻚面的关闭
     *
     * @param promise
     */
    @ReactMethod
    public void quitLoginPage(final Promise promise) {
        phoneNumberAuthHelper.quitLoginPage();
        COMMON_PROMISE = promise;
    }

    /**
     * 退出登录授权⻚时,授权⻚的 loading 消失由 APP 控制
     *
     * @param promise
     */
    @ReactMethod
    public void hideLoginLoading(final Promise promise) {
        phoneNumberAuthHelper.hideLoginLoading();
        COMMON_PROMISE = promise;
    }


    /**
     * 判断运营商类型
     *
     * @param promise
     */
    @ReactMethod
    public void getOperatorType(final Promise promise) {
        if (!checkInit(promise)) {
            return;
        }
        String carrierName = phoneNumberAuthHelper.getCurrentCarrierName();
        if (carrierName.equals("CMCC")) {
            carrierName = "中国移动";
        } else if (carrierName.equals("CUCC")) {
            carrierName = "中国联通";
        } else if (carrierName.equals("CTCC")) {
            carrierName = "中国电信";
        }
        promise.resolve(carrierName);
    }

    /**
     * 设置界面UI
     *
     * @param config
     */
    @ReactMethod
    public void setUIConfig(final ReadableMap config, final Promise promise) {
        if (!checkInit(promise)) {
            return;
        }
        AuthUIConfig.Builder builder = new AuthUIConfig.Builder();
        setSloganUI(builder, config);
        setNavBarUI(builder, config);
        setLogBtnUI(builder, config);
        setSwitchAccUI(builder, config);
        setStatusBarUI(builder, config);
        setLogoUI(builder, config);
        setNumberUI(builder, config);
        setPrivacyUI(builder, config);
        setOtherUI(builder, config);
        phoneNumberAuthHelper.setAuthUIConfig(builder.create());
        COMMON_PROMISE = promise;

    }

 // dialog登录
    @ReactMethod
    public void setDialogUIConfig(final ReadableMap config, final Promise promise) {
        phoneNumberAuthHelper.removeAuthRegisterXmlConfig();
        phoneNumberAuthHelper.removeAuthRegisterViewConfig();
        int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
        if (Build.VERSION.SDK_INT == 26) {
            authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
        }
        updateScreenSize(authPageOrientation);
        int dialogWidth = (int) (mScreenWidthDp * 0.8f);
        int dialogHeight = (int) (mScreenHeightDp * 0.65f);
        int logBtnOffset = dialogHeight / 2;

        AuthUIConfig.Builder builder = new AuthUIConfig.Builder();
        setSloganUI(builder, config);
        setNavBarUI(builder, config);
        setLogBtnUI(builder, config);
        setSwitchAccUI(builder, config);
        setStatusBarUI(builder, config);
        setLogoUI(builder, config);
        setNumberUI(builder, config);
        setPrivacyUI(builder, config);
        setOtherUI(builder, config);

        setDialogUIHeight(builder, config, dialogHeight);
        builder.setLogBtnWidth(dialogWidth - 30)
//                .setAuthPageActIn("in_activity", "out_activity")
//                .setAuthPageActOut("in_activity", "out_activity")
                .setDialogWidth(dialogWidth)
//                .setDialogHeight(dialogHeight)
                .setDialogBottom(false)
                //.setDialogAlpha(82)
//                .setLogoImgPath("ic_launcher")
                .setScreenOrientation(authPageOrientation);

        phoneNumberAuthHelper.setAuthUIConfig(builder.create());
        COMMON_PROMISE = promise;

    }


    // 弹窗授权⻚⾯
    private void configLoginTokenPortDialog(ReadableMap config) {
        // initDynamicView();
        phoneNumberAuthHelper.removeAuthRegisterXmlConfig();
        phoneNumberAuthHelper.removeAuthRegisterViewConfig();
        int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
        if (Build.VERSION.SDK_INT == 26) {
            authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
        }
        updateScreenSize(authPageOrientation);
        int dialogWidth = (int) (mScreenWidthDp * 0.8f);
        int dialogHeight = (int) (mScreenHeightDp * 0.65f);

        int logBtnOffset = dialogHeight / 2;
        phoneNumberAuthHelper.setAuthUIConfig(
                new AuthUIConfig.Builder()
                        // .setAppPrivacyOne("《自定义隐私协议》", "https://www.baidu.com")
                        .setAppPrivacyColor(Color.GRAY, Color.parseColor("#FFA346"))
                        .setPrivacyState(false)
                        .setCheckboxHidden(true)
//            .setNavHidden(false)
//            .setNavColor(Color.parseColor("#FFA346"))
//            .setNavReturnImgPath("icon_close")
                        .setWebNavColor(Color.parseColor("#FFA346"))
                        .setAuthPageActIn("in_activity", "out_activity")
                        .setAuthPageActOut("in_activity", "out_activity")
                        .setVendorPrivacyPrefix("《")
                        .setVendorPrivacySuffix("》")
                        .setLogoImgPath("ic_launcher")
                        .setLogBtnWidth(dialogWidth - 30)
                        .setLogBtnMarginLeftAndRight(15)
                        .setLogBtnBackgroundPath("button")
                        .setLogoOffsetY(48)
                        .setLogoWidth(42)
                        .setLogoHeight(42)
                        .setLogBtnOffsetY(logBtnOffset)
                        .setSloganText("为了您的账号安全，请先绑定手机号")
                        .setSloganOffsetY(logBtnOffset - 100)
                        .setSloganTextSize(11)
                        .setNumFieldOffsetY(logBtnOffset - 50)
                        .setSwitchOffsetY(logBtnOffset + 50)
                        .setSwitchAccTextSize(11)
//            .setPageBackgroundPath("dialog_page_background")
                        .setNumberSize(17)
                        .setLogBtnHeight(38)
                        .setLogBtnTextSize(16)
                        .setDialogWidth(dialogWidth)
                        .setDialogHeight(dialogHeight)
                        .setDialogBottom(false)
//            .setDialogAlpha(82)
                        .setScreenOrientation(authPageOrientation)
                        .create()
        );
    }

    /**
     * 将方法名转为key名
     * @param methodName
     * @return
     */
    private String methodName2KeyName(String methodName) {
        String result = "";
        if (methodName == null) {
            return result;
        }
        if (methodName.startsWith("set")) {
            result = methodName.substring(3);
        }
        String firstChar = result.substring(0, 1); // 首字母
        String otherChar = result.substring(1); // 首字母
        Log.d(methodName, firstChar.toLowerCase() + otherChar);
        return firstChar.toLowerCase() + otherChar;
    }

    private void setDialogUIHeight(AuthUIConfig.Builder builder, ReadableMap config, int defaultHeight) {
        if (config.hasKey(methodName2KeyName("setDialogHeightDelta"))) {
            builder.setDialogHeight(defaultHeight - config.getInt(methodName2KeyName("setDialogHeightDelta")));
        }
    }

    /**
     * 标题栏UI设置
     */
    private void setNavBarUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setNavColor"))) {
            builder.setNavColor(Color.parseColor(config.getString(methodName2KeyName("setNavColor"))));
        }
        if (config.hasKey(methodName2KeyName("setNavText"))) {
            builder.setNavText(config.getString(methodName2KeyName("setNavText")));
        }
        if (config.hasKey(methodName2KeyName("setNavTextColor"))) {
            builder.setNavTextColor(Color.parseColor(config.getString(methodName2KeyName("setNavTextColor"))));
        }
        if (config.hasKey(methodName2KeyName("setNavTextSize"))) {
            builder.setNavTextSize(config.getInt(methodName2KeyName("setNavTextSize")));
        }
        if (config.hasKey(methodName2KeyName("setNavReturnImgPath"))) {
            builder.setNavReturnImgPath(config.getString(methodName2KeyName("setNavReturnImgPath")));
            builder.setNavReturnScaleType(ImageView.ScaleType.FIT_CENTER);
        }
        if (config.hasKey(methodName2KeyName("setNavReturnImgWidth"))) {
            builder.setNavReturnImgWidth(config.getInt(methodName2KeyName("setNavReturnImgWidth")));
        }
        if (config.hasKey(methodName2KeyName("setNavReturnImgHeight"))) {
            builder.setNavReturnImgHeight(config.getInt(methodName2KeyName("setNavReturnImgHeight")));
        }
        // webView
        if (config.hasKey(methodName2KeyName("setWebNavColor"))) {
            builder.setWebNavColor(Color.parseColor(config.getString(methodName2KeyName("setWebNavColor"))));
        }
        if (config.hasKey(methodName2KeyName("setWebNavTextColor"))) {
            builder.setWebNavTextColor(Color.parseColor(config.getString(methodName2KeyName("setWebNavTextColor"))));
        }
        if (config.hasKey(methodName2KeyName("setWebNavTextSize"))) {
            builder.setWebNavTextSize(config.getInt(methodName2KeyName("setWebNavTextSize")));
        }

        if (config.hasKey(methodName2KeyName("setNavHidden"))) {
          builder.setNavHidden(config.getBoolean(methodName2KeyName("setNavHidden")));
      }
    }

    /**
     * 运营商宣传UI设置
     */
    private void setSloganUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setSloganText"))) {
            builder.setSloganText(config.getString(methodName2KeyName("setSloganText")));
        }
        if (config.hasKey(methodName2KeyName("setSloganTextColor"))) {
            builder.setSloganTextColor(Color.parseColor(config.getString(methodName2KeyName("setSloganTextColor"))));
        }
        if (config.hasKey(methodName2KeyName("setSloganTextSize"))) {
            builder.setSloganTextSize(config.getInt(methodName2KeyName("setSloganTextSize")));
        }
        if (config.hasKey(methodName2KeyName("setSloganOffsetY"))) {
            builder.setSloganOffsetY(config.getInt(methodName2KeyName("setSloganOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setSloganOffsetY_B"))) {
            builder.setSloganOffsetY_B(config.getInt(methodName2KeyName("setSloganOffsetY_B")));
        }
    }

    /**
     * 登录按钮UI设置
     */
    private void setLogBtnUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setLogBtnText"))) {
            builder.setLogBtnText(config.getString(methodName2KeyName("setLogBtnText")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnTextColor"))) {
            builder.setLogBtnTextColor(Color.parseColor(config.getString(methodName2KeyName("setLogBtnTextColor"))));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnTextSize"))) {
            builder.setLogBtnTextSize(config.getInt(methodName2KeyName("setLogBtnTextSize")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnWidth"))) {
            builder.setLogBtnWidth(config.getInt(methodName2KeyName("setLogBtnWidth")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnHeight"))) {
            builder.setLogBtnHeight(config.getInt(methodName2KeyName("setLogBtnHeight")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnMarginLeftAndRight"))) {
            builder.setLogBtnMarginLeftAndRight(config.getInt(methodName2KeyName("setLogBtnMarginLeftAndRight")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnBackgroundPath"))) {
            builder.setLogBtnBackgroundPath(config.getString(methodName2KeyName("setLogBtnBackgroundPath")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnOffsetY"))) {
            builder.setLogBtnOffsetY(config.getInt(methodName2KeyName("setLogBtnOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setLogBtnOffsetY_B"))) {
            builder.setLogBtnOffsetY_B(config.getInt(methodName2KeyName("setLogBtnOffsetY_B")));
        }
        if (config.hasKey(methodName2KeyName("setLoadingImgPath"))) {
            builder.setLoadingImgPath(config.getString(methodName2KeyName("setLoadingImgPath")));
        }
    }

    /**
     * 切换其他登录方式UI设置
     */
    private void setSwitchAccUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setSwitchAccHidden"))) {
            builder.setSwitchAccHidden(config.getBoolean(methodName2KeyName("setSwitchAccHidden")));
        }
        if (config.hasKey(methodName2KeyName("setSwitchAccText"))) {
            builder.setSwitchAccText(config.getString(methodName2KeyName("setSwitchAccText")));
        }
        if (config.hasKey(methodName2KeyName("setSwitchAccTextSize"))) {
            builder.setSwitchAccTextSize(config.getInt(methodName2KeyName("setSwitchAccTextSize")));
        }
        if (config.hasKey(methodName2KeyName("setSwitchOffsetY"))) {
            builder.setSwitchOffsetY(config.getInt(methodName2KeyName("setSwitchOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setSwitchOffsetY_B"))) {
            builder.setSwitchOffsetY_B(config.getInt(methodName2KeyName("setSwitchOffsetY_B")));
        }
        if (config.hasKey(methodName2KeyName("setSwitchAccTextColor"))) {
            builder.setSwitchAccTextColor(Color.parseColor(config.getString(methodName2KeyName("setSwitchAccTextColor"))));
        }
    }

    /**
     * 状态栏
     */
    private void setStatusBarUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setStatusBarColor"))) {
            builder.setStatusBarColor(Color.parseColor(config.getString(methodName2KeyName("setStatusBarColor"))));
        }
        if (config.hasKey(methodName2KeyName("setLightColor"))) {
            builder.setLightColor(config.getBoolean(methodName2KeyName("setLightColor")));
        }
        if (config.hasKey(methodName2KeyName("setStatusBarHidden"))) {
            builder.setStatusBarHidden(config.getBoolean(methodName2KeyName("setStatusBarHidden")));
        }
    }

    /**
     * logo
     */
    private void setLogoUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setLogoImgPath"))) {
            builder.setLogoImgPath(config.getString(methodName2KeyName("setLogoImgPath")));
        }
        if (config.hasKey(methodName2KeyName("setLogoHidden"))) {
            builder.setLogoHidden(config.getBoolean(methodName2KeyName("setLogoHidden")));
        }
        if (config.hasKey(methodName2KeyName("setLogoWidth"))) {
            builder.setLogoWidth(config.getInt(methodName2KeyName("setLogoWidth")));
        }
        if (config.hasKey(methodName2KeyName("setLogoHeight"))) {
            builder.setLogoHeight(config.getInt(methodName2KeyName("setLogoHeight")));
        }
        if (config.hasKey(methodName2KeyName("setLogoOffsetY"))) {
            builder.setLogoOffsetY(config.getInt(methodName2KeyName("setLogoOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setLogoOffsetY_B"))) {
            builder.setLogoOffsetY_B(config.getInt(methodName2KeyName("setLogoOffsetY_B")));
        }
    }

    /**
     * 掩码UI
     */
    private void setNumberUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setNumberColor"))) {
            builder.setNumberColor(Color.parseColor(config.getString(methodName2KeyName("setNumberColor"))));
        }
        if (config.hasKey(methodName2KeyName("setNumberSize"))) {
            builder.setNumberSize(config.getInt(methodName2KeyName("setNumberSize")));
        }
        if (config.hasKey(methodName2KeyName("setNumberFieldOffsetX"))) {
            builder.setNumberFieldOffsetX(config.getInt(methodName2KeyName("setNumberFieldOffsetX")));
        }
        if (config.hasKey(methodName2KeyName("setNumberFieldOffsetY"))) {
            builder.setNumFieldOffsetY(config.getInt(methodName2KeyName("setNumberFieldOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setNumberFieldOffsetY_B"))) {
            builder.setNumFieldOffsetY_B(config.getInt(methodName2KeyName("setNumberFieldOffsetY_B")));
        }
    }

    /**
     * 协议
     */
    private void setPrivacyUI(AuthUIConfig.Builder builder, ReadableMap config) {
        if (config.hasKey(methodName2KeyName("setAppPrivacyOneName")) && config.hasKey(methodName2KeyName("setAppPrivacyOneUrl"))) {
            builder.setAppPrivacyOne(config.getString(methodName2KeyName("setAppPrivacyOneName")), config.getString(methodName2KeyName("setAppPrivacyOneUrl")));
        }
        if (config.hasKey(methodName2KeyName("setAppPrivacyTwoName")) && config.hasKey(methodName2KeyName("setAppPrivacyTwoUrl"))) {
            builder.setAppPrivacyTwo(config.getString(methodName2KeyName("setAppPrivacyTwoName")), config.getString(methodName2KeyName("setAppPrivacyTwoUrl")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyState"))) {
            builder.setPrivacyState(config.getBoolean(methodName2KeyName("setPrivacyState")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyTextSize"))) {
            builder.setPrivacyTextSize(config.getInt(methodName2KeyName("setPrivacyTextSize")));
        }
        if (config.hasKey(methodName2KeyName("setAppPrivacyBaseColor")) && config.hasKey(methodName2KeyName("setAppPrivacyColor"))) {
            builder.setAppPrivacyColor(Color.parseColor(config.getString(methodName2KeyName("setAppPrivacyBaseColor"))), Color.parseColor(config.getString(methodName2KeyName("setAppPrivacyColor"))));
        }
        if (config.hasKey(methodName2KeyName("setVendorPrivacyPrefix"))) {
            builder.setVendorPrivacyPrefix(config.getString(methodName2KeyName("setVendorPrivacyPrefix")));
        }
        if (config.hasKey(methodName2KeyName("setVendorPrivacySuffix"))) {
            builder.setVendorPrivacySuffix(config.getString(methodName2KeyName("setVendorPrivacySuffix")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyBefore"))) {
            builder.setPrivacyBefore(config.getString(methodName2KeyName("setPrivacyBefore")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyEnd"))) {
            builder.setPrivacyEnd(config.getString(methodName2KeyName("setPrivacyEnd")));
        }
        if (config.hasKey(methodName2KeyName("setCheckboxHidden"))) {
            builder.setCheckboxHidden(config.getBoolean(methodName2KeyName("setCheckboxHidden")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyOffsetY"))) {
            builder.setPrivacyOffsetY(config.getInt(methodName2KeyName("setPrivacyOffsetY")));
        }
        if (config.hasKey(methodName2KeyName("setPrivacyOffsetY_B"))) {
            builder.setPrivacyOffsetY_B(config.getInt(methodName2KeyName("setPrivacyOffsetY_B")));
        }
    }

    /**
     * 其他
     */
    private void setOtherUI(AuthUIConfig.Builder builder, ReadableMap config) {
      if (config.hasKey(methodName2KeyName("setPageBackgroundPath"))) {
        builder.setPageBackgroundPath(config.getString(methodName2KeyName("setPageBackgroundPath")));
    }
    }

    private void sendEvent(String eventName, WritableMap params) {
        try {
            this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        } catch (RuntimeException e) {
            Log.e("ERROR", "java.lang.RuntimeException: Trying to invoke Javascript before CatalystInstance has been set!");
        }
    }

    private void updateScreenSize(int authPageScreenOrientation) {
        int screenHeightDp = AppUtils.px2dp(reactContext, AppUtils.getPhoneHeightPixels(reactContext));
        int screenWidthDp = AppUtils.px2dp(reactContext, AppUtils.getPhoneWidthPixels(reactContext));
        mScreenWidthDp = screenWidthDp;
        mScreenHeightDp = screenHeightDp;
    }
}
