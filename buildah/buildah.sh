#!/bin/bash -e

help () {
  echo ' 打包oci镜像.'
  echo ' 选项:'
  echo ' -f: Dockerfile路径 默认 deploy/Dockerfile'
  echo ' -t: 部署镜像名称Tag 必需'
  echo ' 使用示例：/buildah.sh -f=Dockerfile -t=core.harbor.brycehan.com/bryce/bryce-admin:latest'
}

case $1 in
  -h|--help) help; exit;;
esac

if [ "$1" == '' ]; then
  help;
  exit;
fi

ARGS=$*
for ARG in $ARGS;
do
  key=$(echo "$ARG" | awk -F"=" '{print $1}')
  value=$(echo "$ARG" | awk -F"=" '{print $2}')
  case $key in
  -f) DOCKER_FILE=$value;;
  -t) IMAGE_NAME=$value;;
  esac
done

DOCKER_FILE=${DOCKER_FILE:-deploy/Dockerfile}

echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
echo -e "\033[32;1m                       |  开始打包上传镜像  |                       \033[0m"
echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"

cat < /password.txt | buildah login -u "$HARBOR_USERNAME" --password-stdin "$HARBOR_HOST" --tls-verify=false
buildah build -f "$DOCKER_FILE" -t "$IMAGE_NAME" .
buildah push --tls-verify=false "$IMAGE_NAME"

echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
echo -e "\033[32;1m                       |  镜像打包上传完毕  |                       \033[0m"
echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
