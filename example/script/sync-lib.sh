#!/usr/bin/env bash

# 同步源代码

# 源代码目录
srcPath=../
modulePath=node_modules/react-native-ali-onepass/
# 需要复制的文件/文件夹
sourceDirs=(android ios index.js package.json)

# 先删除已存在的node_module
rm -rf "${modulePath}"
mkdir "${modulePath}"

echo "开始拷贝"

for path in ${sourceDirs[*]}; do
  echo "拷贝目录/文件：${path}"
  fromPath=${srcPath}${path}
  toPath=${modulePath}${path}
  cp -r "${fromPath}" "${toPath}"
done

echo "拷贝完成"

# 安装依赖
echo "开始安装依赖"

cd ${modulePath} || exit
yarn

echo "依赖安装完成"
