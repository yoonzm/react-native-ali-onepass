#!/bin/bash

# 上传至蒲公英
# 参数1 文件路径
# 参数1 版本描述
uploadPGY() {
    echo "上传至蒲公英----------------------------------------------------------------"
    echo "上传文件" $1
    echo "上传描述" $2
    echo "开始上传----------------------------------------------------------------"
    curl \
    -F "file=@$1" \
    -F '_api_key=c1449303211b4837129a239d2dd4dc30' \
    -F "buildUpdateDescription=$2" \
    -F "buildInstallType=2" \
    -F "buildPassword=0000" \
    https://www.pgyer.com/apiv2/app/upload
}

case "$1" in
    uploadPGY)
        $1 $2 $3
        ;;
    *)
        echo $"Usage: $0 {uploadPGY}"
        exit 2
esac
exit $?
