#######################################################################################################
#
# Yellowfin Database Installer
#
# An image that will install a Yellowfin database with given DB credentials, if the Yellowfin schema is not currently present.
#
# Options can be passed to the image on startup with the -e command
#
#  DATABASE_TYPE  (Mandatory)        DBMS Type: PostgreSQL, MySQL, Oracle, SQLServer
#  DATABASE_HOST  (Mandatory)        DBMS Hostname or Ip Address
#  DATABASE_PORT  (Mandatory)        DBMS TCP port number
#  DATABASE_NAME  (Mandatory)        Database Name
#  DATABASE_USER  (Mandatory)        Database user for the Yellowfin Repository (can be obtained from the Yellowfin web.xml file)
#  DATABASE_PASSWORD (Mandatory)     Database user's plain-text password
#  
# Standard startup command would be something like:
#
# docker run -e DATABASE_TYPE=PostgreSQL -e DATABASE_HOST=10.10.10.39 -e DATABASE_PORT=5432 -e DATABASE_NAME=yellowfindocker -e DATABASE_USER=admin -e DATABASE_PASSWORD=admin yellowfin-repository-database-install
#
#######################################################################################################

#######################################################################################################
# Fetch the base operating system
#
#######################################################################################################

### From Ubuntu 20 base image
FROM ubuntu:20.04
LABEL maintainer="Yellowfin <support@yellowfin.bi>"
LABEL description="Yellowfin Database Installer"

### Timezone setup
ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Install OS applications required for application installation and setup Java
RUN apt-get update && apt-get install unzip tar curl sed openjdk-8-jre -y

#######################################################################################################
# Fetch the Yellowfin installer
#
# The installer is provided at image creation time. Rename the required JAR file installer to 
# yellowfin-installer.jar # in the same directory as the Dockerfile. JDBC drivers not included with 
# Yellowfin will also needed to be added to the image into the /opt/ folder
#######################################################################################################

COPY yellowfin-installer.jar /tmp/yellowfin-installer.jar
#COPY mysql-driver.jar /opt/mysql-driver.jar

#######################################################################################################
# Prepare schema check assets
#
# Copy in Java tool to list schema, extract JDBC drivers
#######################################################################################################

RUN unzip -j /tmp/yellowfin-installer.jar "yfres/jdbc-drivers/*" -d /opt
COPY ListDatabaseTables.jar /opt

### Create a script to build the connection string to pass to the ListDatabaseTables tool
RUN echo "#!/bin/sh" >> /opt/build-connection-string.sh \ 
&& echo "if [ \"PostgreSQL\" = \"\${DATABASE_TYPE}\" ]; then " >> /opt/build-connection-string.sh \
&& echo "echo jdbc:postgresql://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\" " >> /opt/build-connection-string.sh \
&& echo "exit 0"  >> /opt/build-connection-string.sh \
&& echo "fi"  >> /opt/build-connection-string.sh \
&& echo "if [ \"MySQL\" = \"\${DATABASE_TYPE}\" ]; then " >> /opt/build-connection-string.sh \
&& echo "echo jdbc:mysql://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\" ">> /opt/build-connection-string.sh \
&& echo "exit 0"  >> /opt/build-connection-string.sh \
&& echo "fi"  >> /opt/build-connection-string.sh \
&& echo "if [ \"SQLServer\" = \"\${DATABASE_TYPE}\" ]; then " >> /opt/build-connection-string.sh \
&& echo "echo jdbc:sqlserver://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\" " >> /opt/build-connection-string.sh \
&& echo "exit 0"  >> /opt/build-connection-string.sh \
&& echo "fi"  >> /opt/build-connection-string.sh \
&& echo "if [ \"Oracle\" = \"\${DATABASE_TYPE}\" ]; then " >> /opt/build-connection-string.sh \
&& echo "echo oracle:thin:@\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\":\"\${DATABASE_NAME}\" " >> /opt/build-connection-string.sh \
&& echo "exit 0"  >> /opt/build-connection-string.sh \
&& echo "fi"  >> /opt/build-connection-string.sh \ 
&& echo "Problem generating connection string"  >> /opt/build-connection-string.sh \
&& echo "exit 1"  >> /opt/build-connection-string.sh


#######################################################################################################
# Perform filesystem installation
#
# Prepare directories for PostgreSQL and Yellowfin.
#######################################################################################################

# Prepare Yellowfin filesystem directories
RUN mkdir -p /opt/yellowfin &&  chmod a+w /opt/yellowfin

#######################################################################################################
# Prepare Yellowfin Installation
#
# Create silent installation file for the silent installer
#######################################################################################################

### Create silent installer properties file
RUN echo InstallPath=/opt/yellowfin > /tmp/silent-install.properties \
&& echo InstallTutorialDatabase=false >> /tmp/silent-install.properties \
&& echo ServicePort=8080 >> /tmp/silent-install.properties \
&& echo InstallService=false >> /tmp/silent-install.properties \
&& echo DatabaseType={DATABASE_TYPE} >> /tmp/silent-install.properties \
&& echo CreateYellowfinDB=false >> /tmp/silent-install.properties \
&& echo CreateYellowfinDBUser=false >> /tmp/silent-install.properties \
&& echo DatabaseHostname={DATABASE_HOST} >> /tmp/silent-install.properties \
&& echo DatabaseName={DATABASE_NAME} >> /tmp/silent-install.properties \
&& echo DatabasePort={DATABASE_PORT} >> /tmp/silent-install.properties \
&& echo AppMemory=2048 >> /tmp/silent-install.properties \
&& echo DatabaseDBAUser={DATABASE_USER} >> /tmp/silent-install.properties \
&& echo DatabaseDBAPassword={DATABASE_PASSWORD} >> /tmp/silent-install.properties \
&& echo DatabaseUser={DATABASE_USER} >> /tmp/silent-install.properties \
&& echo DatabasePassword={DATABASE_PASSWORD} >> /tmp/silent-install.properties 


#######################################################################################################
# Prepare Yellowfin Launcher
#
# Create docker entry file, and mark file as docker entry-point
#######################################################################################################


### Execute Installer, copy log file, remove installation
RUN echo "#!/bin/sh" >> /opt/docker-entry.sh \
&& echo "echo ==== Test Existing Schema " >> /opt/docker-entry.sh \
&& echo "export CLASSPATH=/opt/*" >> /opt/docker-entry.sh \  
&& echo "java ListDatabaseTables url:\`sh /opt/build-connection-string.sh\` user:\"\$DATABASE_USER\" password:\"\$DATABASE_PASSWORD\" > /opt/existing_tablelist" >> /opt/docker-entry.sh \  
&& echo "if grep -q 'ACCESSCLASSLIST' /opt/existing_tablelist ; then echo 'Schema Exists - Aborting Installation';exit 1; fi" >> /opt/docker-entry.sh \ 
&& echo "echo ==== Prepare Installer Properties" >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_TYPE}/'\"\$DATABASE_TYPE\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_HOST}/'\"\$DATABASE_HOST\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_PORT}/'\"\$DATABASE_PORT\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_NAME}/'\"\$DATABASE_NAME\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_USER}/'\"\$DATABASE_USER\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "sed -i 's/{DATABASE_PASSWORD}/'\"\$DATABASE_PASSWORD\"'/g' /tmp/silent-install.properties " >> /opt/docker-entry.sh \
&& echo "echo ==== Silent Installer Properties" >> /opt/docker-entry.sh \
&& echo "cat /tmp/silent-install.properties" >> /opt/docker-entry.sh \
&& echo "echo ==== Installing Yellowfin" >> /opt/docker-entry.sh \
&& echo "java -jar /tmp/yellowfin-installer.jar -silent /tmp/silent-install.properties" >> /opt/docker-entry.sh \
&& echo "echo ==== Copying Log" >> /opt/docker-entry.sh \
&& echo "cp /opt/yellowfin/YellowfinInstallLog* /tmp" >> /opt/docker-entry.sh \
&& echo "echo ==== Clean up installation files" >> /opt/docker-entry.sh \
&& echo "rm /tmp/yellowfin-installer.jar" >> /opt/docker-entry.sh \
&& echo "echo ==== Remove installation" >> /opt/docker-entry.sh \
&& echo "rm -r /opt/yellowfin" >> /opt/docker-entry.sh \
&& echo "echo ==== Installation Log" >> /opt/docker-entry.sh \
&& echo "cat /tmp/YellowfinInstallLog*" >> /opt/docker-entry.sh \
&& echo "if grep -q 'Installation Failed' /tmp/YellowfinInstallLog*; then echo 'Installation Failed'; exit 1; fi" >> /opt/docker-entry.sh \
&& echo "echo Installation Successful "  >> /opt/upgrade.sh \ 
&& echo "exit 0 " >> /opt/upgrade.sh

ENTRYPOINT ["/bin/sh", "/opt/docker-entry.sh"]
