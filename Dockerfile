FROM ubuntu:22.04

LABEL author="Cho Phan"

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HIVE_HOME=/usr/local/hive

RUN \
  apt-get update \
  && apt-get install -y \
    sudo \
    openssl

RUN \
  sudo useradd -m -s /bin/bash -p $(openssl passwd -1 chophan) hive \
  && sudo usermod -aG sudo hive \
  && sudo su - hive

USER hive

RUN \
  echo "chophan" | sudo -S apt-get install -y \
    vim \
    wget \
    openjdk-8-jdk \
    ssh \
    iputils-ping \
    mysql-server

RUN mkdir -p /home/hive/Downloads

WORKDIR /home/hive/Downloads

RUN \
  wget \
    https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
    https://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz \
    https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.1.0.tar.gz

RUN \
  tar -zxvf hadoop-3.3.6.tar.gz \
  && tar -zxvf apache-hive-3.1.2-bin.tar.gz \
  && tar -zxvf mysql-connector-j-8.1.0.tar.gz

RUN \
  echo "chophan" | sudo -S mv hadoop-3.3.6 $HADOOP_HOME \
  && sudo mv apache-hive-3.1.2-bin $HIVE_HOME \
  && sudo mv mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar $HIVE_HOME/lib

WORKDIR $HIVE_HOME

RUN echo "chophan" | sudo -S rm -R /home/hive/Downloads

RUN \
  echo "\nexport JAVA_HOME=$JAVA_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$JAVA_HOME/bin\n' >> ~/.bashrc \
  && echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin\n' >> ~/.bashrc \
  && echo "export HIVE_HOME=$HIVE_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc

RUN \
  echo "chophan" | sudo -S rm $HIVE_HOME/lib/guava-19.0.jar \
  && cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

RUN echo "chophan" | sudo -S usermod -d /var/lib/mysql/ mysql

COPY /conf/hive-site.xml $HIVE_HOME/conf/
COPY /conf/hive-env.sh $HIVE_HOME/conf/
COPY /conf/mysqld.cnf /etc/mysql/mysql.conf.d/
COPY /conf/init.sh $HIVE_HOME/
COPY /start-hive.sh $HIVE_HOME/

RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
  && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys

RUN $HIVE_HOME/init.sh

RUN rm $HIVE_HOME/init.sh

ENTRYPOINT ["/bin/bash", "./start-hive.sh"]
