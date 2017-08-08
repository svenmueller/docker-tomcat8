FROM ubuntu:14.04

MAINTAINER Carlos Moro <cmoro@deusto.es>

ENV TOMCAT_VERSION 8.0.28

# Set locales
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LC_CTYPE en_GB.UTF-8

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
apt-get install -y git build-essential curl wget software-properties-common

# Install JDK 8
ENV JAVA_HOME=/usr/java/default
ENV JAVA_VERSION=8u131
RUN apt-get update --quiet \
  && apt-get install --quiet --yes --no-install-recommends curl \
  && apt-get clean \
  && mkdir -p /usr/java \
  && curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/server-jre-${JAVA_VERSION}-linux-x64.tar.gz" > "/tmp/server-jre-${JAVA_VERSION}-linux-x64.tar.gz" \
  && tar zxvf "/tmp/server-jre-${JAVA_VERSION}-linux-x64.tar.gz" -C /usr/java \
  && export JAVA_DIR=$(ls -1 -d /usr/java/*) \
  && echo $JAVA_DIR \
  && ln -s $JAVA_DIR /usr/java/latest \
  && ln -s $JAVA_DIR /usr/java/default \
  && update-alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 20000 \
  && update-alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 20000 \
  && update-alternatives --install /usr/bin/jar jar $JAVA_DIR/bin/jar 20000

# Get Tomcat
RUN wget --quiet --no-cookies http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT

# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/

# Add custom server.xml
ADD server.xml /opt/tomcat/conf/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
WORKDIR /opt/tomcat

# Launch Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
