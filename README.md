
# react-native-ali-onepass

## Getting started

`$ npm install react-native-ali-onepass --save`

`$ yarn add react-native-ali-onepass`

### Mostly automatic installation

`$ react-native link react-native-ali-onepass`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ali-onepass` and add `RNAliOnepass.xcodeproj`
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

## [Example](https://github.com/yoonzm/react-native-ali-onepass/blob/master/example/App.js)

