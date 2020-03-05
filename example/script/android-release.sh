#!/bin/bash

# 安卓自动化打包脚本

cd android

./gradlew clean

build(){
    echo 打包开始
    ./gradlew assembleRelease
    echo 打包结束
}

build

fileNames=`ls ./app/build/outputs/apk/`
for fileName in ${fileNames}
do
    # 当前在android文件夹内
    sh ../script/upload.sh uploadPGY ./app/build/outputs/apk/${fileName} ${fileName}
done
echo "已上传至蒲公英----------------------------------------------------------------------------------------------------"
