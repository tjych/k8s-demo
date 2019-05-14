FROM nimmis/java-centos:openjdk-8-jdk

RUN mkdir -p /workspace/webapps/k8s-demo/webapps
#COPY output /workspace/webapps/k8s-demo/webapps
ADD output/k8s-demo.tar.gz /workspace/webapps/k8s-demo/webapps
RUN chmod +x /workspace/webapps/k8s-demo/webapps/bin/start.sh

CMD ["sh","/workspace/webapps/k8s-demo/webapps/bin/start.sh","start"]