
# react-native-onepass-alibaba

## Getting started

`$ npm install react-native-onepass-alibaba --save`

`$ yarn add react-native-onepass-alibaba`

### Mostly automatic installation

`$ react-native link react-native-onepass-alibaba`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-onepass-alibaba` and add `RNAliOnepass.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAliOnepass.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
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
4. Insert the following lines inside the android block in `android/app/build.gradle`:
  	```
      repositories {
          flatDir {
              dirs 'libs', '../../node_modules/react-native-onepass-alibaba/android/libs'
          }
      }
  	```

## [Example](https://github.com/yoonzm/react-native-ali-onepass/blob/master/example/App.js)

