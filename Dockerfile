FROM phusion/baseimage:0.9.12

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ENV DOWNLOAD_URL https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.8.0.tar.gz

ENV CROWD_HOME /var/atlassian/application-data/crowd

# Install Atlassian Crowd to the following location
ENV CROWD_INSTALL_DIR /opt/atlassian/crowd

RUN apt-get update
RUN apt-get install -y wget git default-jre

RUN sudo /bin/sh -c 'echo JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::") >> /etc/environment'
RUN sudo /bin/sh -c 'echo crowd.home=${CROWD_HOME} >> /etc/environment'

RUN mkdir -p ${CROWD_INSTALL_DIR}
RUN mkdir -p ${CROWD_HOME}

RUN wget -P /tmp ${DOWNLOAD_URL}
RUN tar zxf /tmp/atlassian-crowd-2.8.0.tar.gz -C /tmp
RUN mv /tmp/atlassian-crowd-2.8.0/* ${CROWD_INSTALL_DIR}/

RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz
RUN tar zxf /tmp/mysql-connector-java-5.1.34.tar.gz -C /tmp
RUN mv /tmp/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar ${CROWD_INSTALL_DIR}/apache-tomcat/lib/

RUN mkdir /etc/service/crowd
ADD runit/crowd.sh /etc/service/crowd/run
RUN chmod +x /etc/service/crowd/run

EXPOSE 8080

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*