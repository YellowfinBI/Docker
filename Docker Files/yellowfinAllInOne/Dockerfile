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
FROM ubuntu:22.04
LABEL maintainer="Yellowfin <support@yellowfin.bi>"
LABEL description="Yellowfin All-In-One"

# Timezone setup
ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS applications required for application installation and setup Java
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y unzip tar curl sed fonts-dejavu \
 fontconfig libasound2 libglib2.0-0  postgresql-14 sudo libpangoft2-1.0-0 -y

#Configure Java 11 using Zulu 11 JDK
RUN mkdir /usr/lib/jvm -p && cd /usr/lib/jvm/ && curl -o zulu11.tar.gz https://cdn.azul.com/zulu/bin/zulu11.60.19-ca-fx-jdk11.0.17-linux_x64.tar.gz \
&& tar -xzvf zulu11.tar.gz && mv zulu11.60* zulu11-jdk/ && rm zulu11.tar.gz
ENV JAVA_HOME=/usr/lib/jvm/zulu11-jdk/
ENV PATH="$JAVA_HOME/bin:$PATH"


#######################################################################################################
# Fetch the Yellowfin installer
#
# The installer can be downloaded during provisioning, or by providing the JAR file as part of image
#######################################################################################################

# Download Yellowfin installer JAR
# (This may slow down image creation time)
RUN curl -qL "{$(curl https://build-api.yellowfin.bi/fetch-latest-build)}" -o /tmp/yellowfin.jar

# Alternatively copy in an installer that has been included image
# (This will remove the wait time for downloading the installer during image creation)
# Example syntax for copying in an embedded installer:
#COPY yellowfin-installer.jar /tmp/yellowfin.jar

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
# Create silent installation file, start PostgreSQL and run the silent installer
#######################################################################################################

# Create silent installer properties file
RUN echo InstallPath=/opt/yellowfin > /tmp/silent-install.properties \
&& echo InstallTutorialDatabase=true >> /tmp/silent-install.properties \
&& echo ServicePort=8080 >> /tmp/silent-install.properties \
&& echo InstallService=false >> /tmp/silent-install.properties \
&& echo DatabaseType=PostgreSQL >> /tmp/silent-install.properties \
&& echo CreateYellowfinDB=true >> /tmp/silent-install.properties \
&& echo CreateYellowfinDBUser=false >> /tmp/silent-install.properties \
&& echo DatabaseHostname=localhost >> /tmp/silent-install.properties \
&& echo DatabaseName=yellowfin >> /tmp/silent-install.properties \
&& echo DatabasePort=5432 >> /tmp/silent-install.properties \
&& echo AppMemory=2048 >> /tmp/silent-install.properties \
&& echo DatabaseDBAUser=yellowfindba >> /tmp/silent-install.properties \
&& echo DatabaseDBAPassword=yellowfin >> /tmp/silent-install.properties \
&& echo DatabaseUser=yellowfindba >> /tmp/silent-install.properties \
&& echo DatabasePassword=yellowfin >> /tmp/silent-install.properties \
&& cat /tmp/silent-install.properties

# Start Postgres, Execute Installer and stop Postgres in single step
RUN echo "Starting PostgreSQL" && pg_ctlcluster 14 main start  && pg_ctlcluster 14 main status \
&& echo "Setting up PostgreSQL for Yellowfin Install" \
&& echo "CREATE ROLE yellowfindba LOGIN SUPERUSER PASSWORD 'yellowfin';"  > user_setup.sql \
&& sudo -u postgres psql < user_setup.sql \
&& echo "Installing Yellowfin" && java -jar /tmp/yellowfin.jar -silent /tmp/silent-install.properties \
&& echo "Stopping PostgreSQL" && pg_ctlcluster 14 main stop \
&& echo "Cleaning up files" && rm /tmp/yellowfin.jar


# Mark management scripts as executable
RUN chmod +x /opt/yellowfin/appserver/bin/catalina.sh /opt/yellowfin/appserver/bin/startup.sh /opt/yellowfin/appserver/bin/shutdown.sh

#######################################################################################################
# Prepare Yellowfin Launcher
#
# Create docker entry file, and mark file as docker entry-point
#######################################################################################################

# Create docker-entry file, that starts PostgreSQL and then Yellowfin

RUN echo pg_ctlcluster 14 main start > /opt/docker-entry.sh \
&& echo "echo Over-ride Memory: \$APP_MEMORY" >> /opt/docker-entry.sh \
&& echo "if [ ! -z \"\${APP_MEMORY}\" ]; then " >> /opt/docker-entry.sh \
&& echo " sed -i 's/-Xmx2048m/-Xmx'\"\$APP_MEMORY\"'m/g' /opt/yellowfin/appserver/bin/catalina.sh " >> /opt/docker-entry.sh \
&& echo fi  >> /opt/docker-entry.sh \
&& echo /opt/yellowfin/appserver/bin/catalina.sh run >> /opt/docker-entry.sh



ENTRYPOINT ["/bin/sh", "/opt/docker-entry.sh"]
