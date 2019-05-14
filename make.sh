#!/bin/sh

#判断命令行参数,不符合条件则退出
#第一个参数 ACTION 类型 compile:拉取代码和编译，build:生成镜像，push:上传镜像,run:镜像运行，auto:自动执行所有步骤
#第二个参数 Tag名称 可以不传默认拉取最新TAG。
#镜像默认用DEV配置，随后上线部署时通过confgmag外挂目录

WORKSPACE=$(cd `dirname $0`; pwd)

#配置文件
GITPROJECTNAME='k8s-demo'
GITPATH="git@github.com:tjych/${GITPROJECTNAME}.git"
COMPILE_DIR=${WORKSPACE}/compile
OUTPUT_DIR="output"
NAMESPACE="dev";
PUSHREOMTENAME='birdfiret'

if [[ $# -ge 3 ]] ;then
    ACTION=$1;
	TAG=$2
	ENV=$3
elif [[ $# -ge 2 ]] ;then
    ACTION=$1;
	TAG=$2
	ENV=dev
elif [[ $# -ge 1 ]] ;then
    ACTION=$1;
	TAG=master
	ENV=dev
else
    echo "Usage:compile|build|push TAG ENV instanceName";
 	exit 1;
fi


compile(){
    #进入编译目录
    #删除目录
    rm -rf $COMPILE_DIR
    mkdir $COMPILE_DIR
    cd $COMPILE_DIR
    git clone --branch $TAG $GITPATH ./
    echo "start make ${ENV} ..."
    echo "${pwd}"
    rm -rf ${OUTPUT_DIR}
    mvn clean package -Dmaven.test.skip=true -P ${ENV}
    mv output/k8s-demo/* ../${OUTPUT_DIR}/
    rm -rf output/k8s-demo
    #退出编译目录
    cd ${WORKSPACE}
}


test(){
    cd ${WORKSPACE}
    echo "start test to make ${ENV} ..."
    mvn clean package -P ${ENV}
    rm -rf ${OUTPUT_DIR}
    mv output/k8s-demo ./${OUTPUT_DIR}
    #退出编译目录
    cd ${WORKSPACE}
    run #调用函数
}


#编译镜像
build(){
    echo "docker build ..."
    cd $COMPILE_DIR
    imagename=$(grep "FROM " Dockerfile | awk '{print $2}');
    #pull下最新镜像
    docker pull ${imagename}
    docker build -t ${NAMESPACE}/${ENV}_${GITPROJECTNAME}:latest -f Dockerfile .
    #docker rmi ${NAMESPACE}/${ENV}_${GITPROJECTNAME}:latest
    #docker tag ${NAMESPACE}/${ENV}_${GITPROJECTNAME}:latest ${PUSHREOMTENAME}/${ENV}_${GITPROJECTNAME}:${TAG}
    docker tag ${NAMESPACE}/${ENV}_${GITPROJECTNAME}:latest ${PUSHREOMTENAME}/${ENV}_${GITPROJECTNAME}:latest
    cd ${WORKSPACE}
}

#发布镜像
push(){
    echo "docker push ..."
    cd $COMPILE_DIR
    imagename=$(grep "FROM " Dockerfile | awk '{print $2}');
    #pull下最新镜像
    docker pull ${imagename}
    #docker push ${PUSHREOMTENAME}/${ENV}_${GITPROJECTNAME}:${TAG}
    docker push ${PUSHREOMTENAME}/${ENV}_${GITPROJECTNAME}:latest
    cd ${WORKSPACE}
}


#运行镜像
run(){
    echo "start run"
}

echo ${ACTION}

case "${ACTION}" in
    compile)
        ${ACTION}
        ;;
    build)
        ${ACTION}
        ;;
    push)
        ${ACTION}
        ;;
    run)
        ${ACTION}
       ;;
    test)
        ${ACTION}
       ;;
    auto)
        complie;
        build;
        push;
     ;;
    *)
    echo "Usage:compile|build|push instanceName";
    exit 1;
esac
exit
