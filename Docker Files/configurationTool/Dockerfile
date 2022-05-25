#######################################################################################################
#
# Yellowfin Configuration Updater
#
# Options can be passed to the image on startup with the -e command
#
#  DATABASE_URL  (Mandatory)         Database JDBC URL (can be obtained from the Yellowfin web.xml)
#  DATABASE_USER (Mandatory)         Database user for the Yellowfin Repository (can be obtained from the Yellowfin web.xml file)
#  DATABASE_PASSWORD (Mandatory)     Database user's plain-text password
#
#  CONFIG_<CODE>      Configuration Item to set
#  BOF_<CODE>         Internal Plugin Item to set
#  
# Standard startup command would be something like:
#
# docker run -e DATABASE_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95rc -e DATABASE_USER=sa -e DATABASE_PASSWORD=password yellowfin-repository-database-upgrade 
#	-e CONFIG_EXTERNALURL=http://10.10.10.39:9090 -e BOF_com.hof.interfaces.EventCreation=com.hof.interfaces.DummyEventCreation yellowfin-configuration-tool
#
#######################################################################################################


### Fetch the base operating system
### From Ubuntu 20 base image

FROM ubuntu:20.04
LABEL maintainer="This image is not maintained by Yellowfin"
LABEL description="Yellowfin Configuration Updater"

# Timezone setup

ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Install OS applications required for upgrade application and setup Java

RUN apt-get update -y && apt-get -y install openjdk-8-jre

### Copy i4-core.jar and i4-adapter nto the container. 
### (This can be sourced from an installation of Yellowfin in /Yellowfin/appserver/webapps/ROOT/WEB-INF/lib )
### This process is only compatible with i4-core/i4-adapter versions from Yellowfin 9.7 and later
COPY i4-core.jar /opt/i4-core.jar
COPY i4-adapter.jar /opt/i4-adapter.jar

### Copy and additional drivers required to access the repository database.
### The driver for the repository can be sourced from the /Yellowfin/appserver/webapps/ROOT/WEB-INF/lib folder in a Yellowfin installation
#COPY mysqldriver.jar /opt/mysqldriver.jar
#COPY mssql-jdbc-7.2.1.jre8.jar /opt/mssql-jdbc-7.2.1.jre8.jar
#COPY postgresql-42.2.14.jre7.jar /opt/postgresql-42.2.14.jre7.jar
#COPY jtds-1.2.8_svn.jar /opt/jtds-1.2.8_svn.jar
#COPY ojdbc8.jar /opt/ojdbc8.jar
#COPY hsqldb.jar /opt/hsqldb.jar

### Create upgrade script
### Call configuration modification script.
RUN echo "#!/bin/sh" > /opt/configure.sh \
&& echo "export CLASSPATH=.:/opt/*" >> /opt/configure.sh \
&& echo "java com.hof.standalone.ModifyConfiguration \\" >> /opt/configure.sh \ 
&& echo "jdbcUser:\$DATABASE_USER \\" >> /opt/configure.sh \
&& echo "jdbcPassword:\$DATABASE_PASSWORD \\" >> /opt/configure.sh \
&& echo "jdbcUrl:\$DATABASE_URL \\" >> /opt/configure.sh \
&& echo "ConcealmentProvider:\$CONCEALMENT_PROVIDER " >> /opt/configure.sh 


ENTRYPOINT ["/bin/bash", "/opt/configure.sh"]
