FROM registry.cn-beijing.aliyuncs.com/sndks/base_java_centos
MAINTAINER chenhui.yang@yahoo.com

RUN mkdir -p /workspace/webapps/wss_ktv_sndks_com/webapps
COPY output /workspace/webapps/wss_ktv_sndks_com/webapps

CMD ["sh","/workspace/webapps/wss_ktv_sndks_com/webapps/bin/start.sh","start"]