#######################################################################################################
#
# Yellowfin Database Upgrader
#
# Options can be passed to the image on startup with the -e command
#
#  DATABASE_URL  (Mandatory)         Database JDBC URL (can be obtained from the Yellowfin web.xml)
#  DATABASE_USER (Mandatory)         Database user for the Yellowfin Repository (can be obtained from the Yellowfin web.xml file)
#  DATABASE_PASSWORD (Mandatory)     Database user's plain-text password
#
# Standard startup command would be something like:
#
# docker run -e DATABASE_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95rc -e DATABASE_USER=sa -e DATABASE_PASSWORD=password yellowfin-repository-database-upgrade
#
#######################################################################################################


#######################################################################################################
#
# Building Instructions
#
# docker build . -t yellowfin-repository-database-upgrade   
#
# Prerequisites:
#
#   Yellowfin Upgrader: The version of Yellowfin you wish to have the image update too. The Yellowfin upgrade JAR file 
#						must be placed in the current directory at build time, and renamed yellowfin-updater.jar.
#
#   Database Drivers:   If the JDBC drivers for accessing the Yellowfin Repository are not bundled with Yellowfin, these
#						can be passed to docker image at build time. These should be copied into the /opt directory with
#						a COPY command. (Example is commented-out below). An alternative to this, is to embed the required driver
#						inside the Yellowfin upgrade JAR file directly.
#
#######################################################################################################


### Fetch the base operating system
### From Ubuntu 20 base image

FROM ubuntu:20.04
LABEL maintainer="This image is not maintained by Yellowfin"
LABEL description="Yellowfin Repository Database Upgrader"

### Timezone setup

ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Install OS applications required for upgrade application and setup Java

RUN apt-get update -y && apt-get -y install openjdk-8-jre

COPY yellowfin-updater.jar /opt/yellowfin-updater.jar

### Copy and additional drivers required to access the repository database.
COPY mysql-connector-java-8.0.23.jar /opt/mysqldriver.jar

### Create upgrade script
### Call Patch installer with provided database details
### Display Patch Log
### Return 0 or 1 based on whether install log contains "Installation Complete"

RUN echo "#!/bin/sh" > /opt/upgrade.sh \
&& echo "export CLASSPATH=.:/opt/*" >> /opt/upgrade.sh \
&& echo "java com.hof.patch.PatchInstaller \\" >> /opt/upgrade.sh \ 
&& echo "-silent option.upgrade=database \\"  >> /opt/upgrade.sh \
&& echo "jdbcUser=\$DATABASE_USER \\" >> /opt/upgrade.sh \
&& echo "jdbcPassword=\$DATABASE_PASSWORD \\" >> /opt/upgrade.sh \
&& echo "jdbcURL=\$DATABASE_URL " >> /opt/upgrade.sh \
&& echo "cat YellowfinPatchLog* " >> /opt/upgrade.sh \
&& echo "if grep -q \"Installation Complete\" YellowfinPatchLog*; then exit 0; fi" >> /opt/upgrade.sh \
&& echo "echo \"Not Successful\" "  >> /opt/upgrade.sh \ 
&& echo "exit 1 " >> /opt/upgrade.sh


ENTRYPOINT ["/bin/sh", "/opt/upgrade.sh"]
