#!/bin/bash

./update_node_modules.sh

cd ios || exit

rm -rf build
rm -rf DerivedData
rm -rf ./IPADir/*

today=$(date +%Y-%m-%d)

# ios自动化打包脚本
project_path=$(pwd)

#工程名 将XXX替换成自己的工程名
project_name=onepass

#build文件夹路径
build_path=${project_path}/build

exportOptionsPlistPath=${project_path}/${project_name}/Info.plist

# 参数1 ENV 参数2 VERSION_TYPE 参数3 NET_EASE_IM_KEY
build(){
    now=$(date +%Y_%m_%d_%H_%M)

    #压缩
    npm run ios-build

    archivePath=~/Library/Developer/Xcode/Archives/${today}/${project_name}-${now}.xcarchive

    xcodebuild \
    archive -workspace "${project_path}"/${project_name}.xcodeproj/project.xcworkspace \
    -scheme ${project_name} \
    -archivePath "${archivePath}" || exit

    #导出.ipa文件所在路径

    exportIpaPath=${project_path}/IPADir/${project_name}_${now}

    xcodebuild \
    -exportArchive \
    -archivePath "${archivePath}" \
    -exportPath "${exportIpaPath}" \
    -exportOptionsPlist "${exportOptionsPlistPath}" \
    || exit

    echo 打包结束
}

build

# 上传至蒲公英
fileNames=$(ls ./IPADir/)
for fileName in ${fileNames}
do
    # 当前在android文件夹内
    sh ../script/upload.sh uploadPGY ./IPADir/"${fileName}"/${project_name}.ipa "${fileName}"
#    rm -rf ./IPADir/${fileName}
done
echo "已上传至蒲公英----------------------------------------------------------------------------------------------------"
