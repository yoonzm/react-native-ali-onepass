# react-native-ali-onepass
阿里云一键登录功能react-native库

## Getting started

`$ npm install react-native-ali-onepass＠git@swifthealthgitlab.com:yin/react-native-ali-onepass.git --save`

### Mostly automatic installation

`$ react-native link react-native-ali-onepass`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ali-onepass` and add `RNAliOnepass.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAliOnepassa` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNAliOnepassPackage;` to the imports at the top of the file
  - Add `new RNAliOnepassPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ali-onepass'
  	project(':react-native-ali-onepass').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ali-onepass/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-ali-onepass')
  	```

## 手动添加
### Android
1. 在主工程的`app/build.gradle`中加入
    ```
    repositories {
        flatDir {
            dirs 'libs', '../../node_modules/react-native-ali-onepass/android/libs'
        }
    }
    ```
2. 若出现
   ```
    Attribute application@allowBackup value=(true) from AndroidManifest.xml
   ```
   在AndroidManifest.xml中添加

   `manifest`节点
   ```
   xmlns:tools="http://schemas.android.com/tools"
   ```

   `application`节点
   ```
   tools:replace="android:allowBackup"
   ```

### Ios
1. 将./ios/libs中的四个库framework添加到主工程的TARGETS->Embedded Binaries中(请勾选Copy items if needed选项)

## Usage
## [Example](./example)
