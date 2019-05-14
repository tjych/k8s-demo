FROM openjdk:7
MAINTAINER chenhui.yang@yahoo.com

RUN mkdir -p /workspace/webapps/k8s-demo/webapps
COPY output /workspace/webapps/k8s-demo/webapps

CMD ["sh","/workspace/webapps/k8s-demo/webapps/bin/start.sh","start"]