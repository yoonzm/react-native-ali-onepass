#!/usr/bin/env bash

# 同步源代码

srcPath=../
modulePath=node_modules/react-native-ali-onepass/

sync(){
    # 子模块路径
    subPath=$1
    # 要同步的文件夹
    dirs=$2

    echo "subPath: "${subPath}
    echo "dirs: "${dirs}

    for path in ${dirs}
    do

    fromPath=${srcPath}${subPath}${path}
    toPath=${modulePath}${subPath}${path}

    rm -rf ${toPath}
    cp -r ${fromPath} ${toPath}
    done
}

# android
sourceDirs=(libs src)
sync android/ "${sourceDirs[*]}"

# ios
sourceDirs=()
sync ios/ "$(ls ${srcPath}ios)"

# src
#sourceDirs=()
#sync src/ "$(ls ${srcPath}src)"

# other
sourceDirs=(index.js)
sync ./ "${sourceDirs[*]}"
