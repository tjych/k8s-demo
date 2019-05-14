#!/bin/sh
#判断命令行参数,不符合条件则退出
WORKSPACE=$(cd "$(dirname "$0")";cd ../;pwd);
INSTANCE_NAME="K8sDemoService";
ACTION="";
DEBUG="";
DAEMON="undaemon";
if [[ $# -ge 1 ]] ;then
	ACTION=$1;
else
	echo "Usage:start|stop|restart daemon|undaemon instanceName debug|jmx";
	exit 1;
fi

if [[ $# -ge 2 ]] ;then
    DAEMON=$2
	INSTANCE_NAME=$3;
	DEBUG=$4;
fi

cd ${WORKSPACE}
CONF_DIR=${WORKSPACE}/conf/
LIB_DIR=${WORKSPACE}/lib
LOGS_DIR=/workspace/logs/service/${INSTANCE_NAME}
if [ ! -d "${LOGS_DIR}" ]; then
	mkdir -p ${LOGS_DIR}
fi
COMMAND="java"
MAIN_CLASS="com.firebird.k8s.demo.Launcher"
JAVA_OPTS="-server -classpath "${CONF_DIR}:${LIB_DIR}/*" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
#JAVA_MEM_OPTS="-Xmx2g -Xms2g -Xmn1024m -XX:MaxMetaspaceSize=128m -Xss512k -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly"
JAVA_MEM_OPTS="-Xmx128m -Xms128m -Xmn256m -Xss512k"
JAVA_GC_OPTS="-XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -Xloggc:${LOGS_DIR}/gc.log"

JAVA_DEBUG_OPTS=""
if [ "${DEBUG}" = "debug" ]; then
    JAVA_DEBUG_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
if [ "${DEBUG}" = "jmx" ]; then
    JAVA_DEBUG_OPTS="-Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi

start(){
	PID=$(ps aux |grep ${INSTANCE_NAME} |grep -v 'grep' |head -n1 |awk '{print $2}');
	if [[ $PID -gt 0 ]] ;then
		echo -e "${INSTANCE_NAME} is \033[32m [running...]\033[0m";
		return;
	fi

	if [ "${DAEMON}" = "daemon" ]; then
	    echo -e "start ${INSTANCE_NAME}:\c"
	    ${COMMAND} ${JAVA_OPTS} ${JAVA_MEM_OPTS} ${JAVA_DEBUG_OPTS} ${JAVA_GC_OPTS} ${MAIN_CLASS} ${INSTANCE_NAME} > ${LOGS_DIR}/stdout.log 2>&1 &
    else
        echo -e "starting ${INSTANCE_NAME} daemon ......\c"
        ${COMMAND} ${JAVA_OPTS} ${JAVA_MEM_OPTS} ${JAVA_DEBUG_OPTS} ${JAVA_GC_OPTS} ${MAIN_CLASS} ${INSTANCE_NAME} > ${LOGS_DIR}/stdout.log 2>&1
	fi
	PID=$(ps aux |grep ${INSTANCE_NAME} |grep -v 'grep' |head -n1 |awk '{print $2}');
	if [[ $PID -gt 0 ]] ;then
		echo -e "\t\t\t \033[32m [OK]\033[0m";
	else
		echo -e "\t\t\t \033[31m [Fail]\033[0m";
	fi
}

stop(){
	i=1;
	MAX_STOP_NUM=30;
	PID=$(ps aux |grep ${INSTANCE_NAME} |grep -v 'grep' |head -n1 |awk '{print $2}');
	OPID=$PID;
	if [[ $PID -gt 0 ]] ;then
		echo -e "stop ${INSTANCE_NAME}:\c";
	else
		echo -e "${INSTANCE_NAME} no start...";
		return;
	fi
	while [[ $PID -gt 0 ]] ;do
		if [[ $i -ge ${MAX_STOP_NUM} ]] ;then
			kill $PID;
			echo -e "${INSTANCE_NAME} \033[31m [Stop Fail]\033[0m";
			break;
		else
			kill $PID;
		fi
		i=`expr $i + 1`;
		sleep 3;
		PID=$(ps aux |grep ${INSTANCE_NAME} |grep -v 'grep' |head -n1 |awk '{print $2}');
	done
	if [[ $OPID -gt 0 ]] ;then
		echo -e "\t\t\t \033[32m [OK]\033[0m";
	fi
}

case "${ACTION}" in
    start)
        ${ACTION}
        ;;
    stop)
        ${ACTION}
        ;;
    restart)
    	stop;
        start;
        ;;
    *)
        echo "Usage:start|stop|restart instanceName debug|jmx";
        exit 1;
esac
