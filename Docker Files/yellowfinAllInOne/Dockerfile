#######################################################################################################
#
# Yellowfin All In One Docker File
#
# An image that will download the latest Yellowfin installer, and install it during Image creation.
# This image includes a PostgreSQL repository built in.
#
# Options can be passed to the image on startup with the -e command
#
#  APP_MEMORY (Optional)             Amount of memory to allocate to the application
#
# Standard startup command would be something like:
#
# docker run -p 9090:8080 -e APP_MEMORY=4096 yellowfin-all-in-one
#
# (Which maps the docker port 8080 to 9090 on the host, and over-rides Yellowfin JVM memory to 4GB.)
#
#######################################################################################################

#######################################################################################################
# Fetch the base operating system
#
# The installer can be downloaded during provisioning, or by providing the JAR file as part of image
#######################################################################################################

# From Ubuntu LTS base image
FROM ubuntu:24.04
LABEL maintainer="Yellowfin <support@yellowfin.bi>"
LABEL description="Yellowfin All-In-One"
ARG TARGETPLATFORM

# Timezone setup
ENV TZ=Etc/GMT

RUN <<EOT
 #Install OS packages and set timezone 
 
 #Setup Timezone
 ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 
 echo $TZ > /etc/timezone
 
 #Install OS applications required for application installation and setup Java
 apt-get update -y
 apt-get upgrade -y 
 apt-get install -y unzip tar curl sed fonts-dejavu  fontconfig liboss4-salsa-asound2 libglib2.0-0 postgresql-16 sudo libpangoft2-1.0-0 -y
EOT
 
RUN <<EOT
 #Install Java 
 mkdir /usr/lib/jvm -p 
 echo $TARGETPLATFORM
 cd /usr/lib/jvm/ 
 if [ "$TARGETPLATFORM" = "linux/amd64" ]; then curl -o zuluJava.tar.gz https://cdn.azul.com/zulu/bin/zulu21.42.19-ca-fx-jdk21.0.7-linux_x64.tar.gz; fi; 
 if [ "$TARGETPLATFORM" = "linux/arm64" ]; then curl -o zuluJava.tar.gz https://cdn.azul.com/zulu/bin/zulu21.42.19-ca-fx-jdk21.0.7-linux_aarch64.tar.gz; fi; 

 #Configure Java using Zulu 21 JDK
 cd /usr/lib/jvm/
 mkdir zulu-jdk
 tar -xzf zuluJava.tar.gz -C zulu-jdk --strip-components=1
 rm zuluJava.tar.gz
EOT

ENV JAVA_HOME=/usr/lib/jvm/zulu-jdk/
ENV PATH="$JAVA_HOME/bin:$PATH"


#######################################################################################################
# Fetch the Yellowfin installer
#
# The installer can be downloaded during provisioning, or by providing the JAR file as part of image
#######################################################################################################

# Download Yellowfin installer JAR
# (This may slow down image creation time)
RUN <<EOT 
   #Downloading Latest Yellowfin
   curl -qL "{$(curl https://build-api.yellowfin.bi/fetch-latest-build)}" -o /tmp/yellowfin.jar
EOT

# Alternatively copy in an installer that has been included image
# (This will remove the wait time for downloading the installer during image creation)
# Example syntax for copying in an embedded installer:
#COPY yellowfin-installer.jar /tmp/yellowfin.jar


#######################################################################################################
# Prepare Yellowfin Installation
#
# Create silent installation file, start PostgreSQL and run the silent installer
#######################################################################################################

# Create silent installer properties file
COPY <<EOF /tmp/silent-install.properties
InstallPath=/opt/yellowfin 
InstallTutorialDatabase=true 
ServicePort=8080
InstallService=false 
DatabaseType=PostgreSQL
CreateYellowfinDB=true 
CreateYellowfinDBUser=false 
DatabaseHostname=localhost 
DatabaseName=yellowfin 
DatabasePort=5432  
AppMemory=2048  
DatabaseDBAUser=yellowfindba 
DatabaseDBAPassword=yellowfin 
DatabaseUser=yellowfindba 
DatabasePassword=yellowfin 
EOF

# Start Postgres, Execute Installer and stop Postgres in single step
RUN <<EOT 
  #Configure Postgres and install Yellowfin 
  echo "Starting PostgreSQL" 
  pg_ctlcluster 16 main start
  pg_ctlcluster 16 main status 
  echo "Setting up PostgreSQL for Yellowfin Install" 
  echo "CREATE ROLE yellowfindba LOGIN SUPERUSER PASSWORD 'yellowfin';"  > user_setup.sql 
  sudo -u postgres psql < user_setup.sql 
  echo "Installing Yellowfin" 
  
  #Install Yellowfin
  mkdir -p /opt/yellowfin &&  chmod a+w /opt/yellowfin
  java -jar /tmp/yellowfin.jar -silent /tmp/silent-install.properties 
  echo "Stopping PostgreSQL"  
  pg_ctlcluster 16 main stop 
  echo "Cleaning up files" 
  rm /tmp/yellowfin.jar /user_setup.sql
  
  #Mark management scripts as executable
  chmod +x /opt/yellowfin/appserver/bin/catalina.sh /opt/yellowfin/appserver/bin/startup.sh /opt/yellowfin/appserver/bin/shutdown.sh
EOT


#######################################################################################################
# Prepare Yellowfin Launcher
#
# Create docker entry file, and mark file as docker entry-point
#######################################################################################################

# Create docker-entry file, that starts PostgreSQL and then Yellowfin

COPY <<EOF /opt/docker-entry.sh
pg_ctlcluster 16 main start 
if [ ! -z "\${APP_MEMORY}" ]; then  
echo Over-ride Memory: \$APP_MEMORY 
sed -i 's/-Xmx2048m/-Xmx'"\$APP_MEMORY"'m/g' /opt/yellowfin/appserver/bin/catalina.sh 
fi  
java -cp /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/lib/* com.hof.standalone.ModifyConfiguration  jdbcuser:yellowfindba jdbcpassword:yellowfin jdbcurl:jdbc:postgresql://localhost:5432/yellowfin 
/opt/yellowfin/appserver/bin/catalina.sh run 
EOF

ENTRYPOINT ["/bin/sh", "/opt/docker-entry.sh"]
