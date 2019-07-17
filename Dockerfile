FROM oraclelinux
## docker build -f Dockerfile -t="elk/elasticsearch" .

USER root
ENV UPDATE_VERSION=8u211
ENV JAVA_VERSION=1.8.0_211
ENV JAVA_ARCHIVE jdk-8u211-linux-x64.tar.gz 
ENV JAVA_HOME /opt/jdk/jdk-$JAVA_VERSION
ENV ES_ARCHIVE elasticsearch-7.1.1-x86_64.rpm
RUN yum update -y && \
    yum install -y unzip.x86_64 && \
    yum install -y which.x86_64 && \
    yum install -y mlocate && \
    updatedb && \
    yum clean all && \
    mkdir -p /opt/jdk  && \
    mkdir -p /opt/elk

COPY $JAVA_ARCHIVE /opt/jdk/ 
COPY $ES_ARCHIVE /opt/elk 
WORKDIR /opt/jdk
RUN tar xvf $JAVA_ARCHIVE && \
        alternatives --install /usr/bin/java java /opt/jdk/jdk${JAVA_VERSION}/bin/java 1 && \
        alternatives --install /usr/bin/javac javac /opt/jdk/jdk${JAVA_VERSION}/bin/javac 1 && \
        alternatives --set java /opt/jdk/jdk${JAVA_VERSION}/bin/java && \
        alternatives --set javac /opt/jdk/jdk${JAVA_VERSION}/bin/javac && \
        export JAVA_HOME=/opt/jdk/jdk${JAVA_VERSION}/ && \
        echo "export JAVA_HOME=/opt/jdk/jdk${JAVA_VERSION}/" | tee /etc/environment && \
        source /etc/environment && \
	rm -f jdk-${UPDATE_VERSION}-linux-x64.tar.gz

ENV JAVA_HOME=/opt/jdk/jdk${JAVA_VERSION}
ENV PATH $JAVA_HOME/bin:/usr/share/elasticsearch:$PATH
WORKDIR /opt/elk
RUN rpm -ivh $ES_ARCHIVE 
WORKDIR /usr/share/elasticsearch

RUN set -ex && for path in data logs config config/scripts; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:root "$path"; \
	chmod -R 775 "$path"; \
    done
COPY logging.yml /usr/share/elasticsearch/config/
COPY elasticsearch.yml /usr/share/elasticsearch/config/

USER elasticsearch
ENV PATH=$PATH:/usr/share/elasticsearch/bin:/usr/share/elasticsearch
CMD ["elasticsearch"]
EXPOSE 9200 

