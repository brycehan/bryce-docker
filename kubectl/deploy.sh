#!/bin/bash -e

help () {
  echo ' 部署应用到 kubernetes.'
  echo ' 选项:'
  echo ' -n: 命名空间 默认 default'
  echo ' -w: 应用部署名称 必需'
  echo ' -i: 部署镜像名称 必需'
  echo ' -c: 容器名称 默认 container-0'
  echo ' -r: 副本数replicas 默认 1'
  echo ' -h: 应用访问域名 必须'
  echo ' -p: 容器暴露端口 默认 80'
  echo ' -a: 启用环境 默认 prod'
  echo ' -d: 每次变更ci的ID 默认通过环境变量 CI_PIPELINE_ID 获取'
  echo ' -m: 最短就绪时间 默认 20'
  echo ' -t: 终止宽限期 默认 30'
  echo ' 使用示例：/deploy.sh -n=default -w=nginx -i=nginx -h=nginx.brycehan.com -a=dev'
}

case $1 in
  -h|--help) help; exit;;
esac

if [ "$1" == '' ]; then
  help;
  exit;
fi

# 默认值
NAMESPACE=default
CONTAINER_NAME=container-0
REPLICAS=1
PORT=80
ACTIVE=prod
minReadySecondsValue=20
terminationGracePeriodSecondsValue=30
# 默认值为空
WORKLOAD=''
IMAGE_NAME=''
HOST=''

ARGS=$*
for ARG in $ARGS;
do
  key=$(echo "$ARG" | awk -F"=" '{print $1}')
  value=$(echo "$ARG" | awk -F"=" '{print $2}')
  case $key in
  -n) NAMESPACE=$value;;
  -w) WORKLOAD=$value;;
  -i) IMAGE_NAME=$value;;
  -c) CONTAINER_NAME=$value;;
  -r) REPLICAS=$value;;
  -h) HOST=$value;;
  -p) PORT=$value;;
  -a) ACTIVE=$value;;
  -d) CI_PIPELINE_ID=$value;;
  -m) minReadySecondsValue=$value;;
  -t) terminationGracePeriodSecondsValue=$value;;
  esac
done

initDeploymentParams() {
  cp /deployment.yaml /opt/deployment.yaml
  sed -i "s=NAMESPACE=${NAMESPACE}=g" /opt/deployment.yaml
  sed -i "s=WORKLOAD=${WORKLOAD}=g" /opt/deployment.yaml
  sed -i "s=IMAGE_NAME=${IMAGE_NAME}=g" /opt/deployment.yaml
  sed -i "s=CONTAINER_NAME=${CONTAINER_NAME}=g" /opt/deployment.yaml
  sed -i "s=REPLICAS=${REPLICAS}=g" /opt/deployment.yaml
  sed -i "s=PORT=${PORT}=g" /opt/deployment.yaml
  sed -i "s=CI_PIPELINE_ID_VALUE=deployment_${CI_PIPELINE_ID}=g" /opt/deployment.yaml
  sed -i "s=ACTIVE=${ACTIVE}=g" /opt/deployment.yaml
  sed -i "s=minReadySecondsValue=${minReadySecondsValue}=g" /opt/deployment.yaml
  sed -i "s=terminationGracePeriodSecondsValue=${terminationGracePeriodSecondsValue}=g" /opt/deployment.yaml
}

initPatchParams() {
  cp /patch.yaml /opt/patch.yaml
  sed -i "s=IMAGE_NAME=${IMAGE_NAME}=g" /opt/patch.yaml
  sed -i "s=CONTAINER_NAME=${CONTAINER_NAME}=g" /opt/patch.yaml
  sed -i "s=CI_PIPELINE_ID_VALUE=deployment_${CI_PIPELINE_ID}=g" /opt/patch.yaml
  sed -i "s=ACTIVE=${ACTIVE}=g" /opt/patch.yaml
  sed -i "s=minReadySecondsValue=${minReadySecondsValue}=g" /opt/patch.yaml
  sed -i "s=terminationGracePeriodSecondsValue=${terminationGracePeriodSecondsValue}=g" /opt/patch.yaml
}

initServiceParams() {
  cp /service.yaml /opt/service.yaml
  sed -i "s=NAMESPACE=${NAMESPACE}=g" /opt/service.yaml
  sed -i "s=WORKLOAD=${WORKLOAD}=g" /opt/service.yaml
  sed -i "s=PORT=${PORT}=g" /opt/service.yaml
}

initIngressParams() {
  cp /ingress.yaml /opt/ingress.yaml
  sed -i "s=NAMESPACE=${NAMESPACE}=g" /opt/ingress.yaml
  sed -i "s=WORKLOAD=${WORKLOAD}=g" /opt/ingress.yaml
  sed -i "s=HOST=${HOST}=g" /opt/ingress.yaml
  sed -i "s=PORT=${PORT}=g" /opt/ingress.yaml
}

deploymentSize=$(kubectl get deployment "$WORKLOAD"  -n "$NAMESPACE" --ignore-not-found=true | awk 'END{print NR}')

echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
echo -e "\033[32;1m                       |  开始部署项目  |                       \033[0m"
echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"

if [ "$deploymentSize" -eq 0 ];then
  initDeploymentParams;
  # 创建deployment
  kubectl apply -f /opt/deployment.yaml

  initServiceParams;
  # 创建service
  kubectl apply -f /opt/service.yaml

  if [ -n "$HOST" ];then
    initIngressParams;
    # 创建ingress
    kubectl apply -f /opt/ingress.yaml
  fi
else
  initPatchParams;
  # 更新patch
  kubectl patch deployment "$WORKLOAD" -n "$NAMESPACE" --patch "$(cat /opt/patch.yaml)"
fi

echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
echo -e "\033[32;1m                       |  项目部署完毕  |                       \033[0m"
echo -e "\033[32;1m ------------------------------------------------------------ \033[0m"
