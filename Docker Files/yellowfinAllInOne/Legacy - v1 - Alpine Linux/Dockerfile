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

# From Postgres 12 Alpine Linux base image
FROM alpine:3.7
LABEL maintainer="Yellowfin <support@yellowfin.bi>"
LABEL description="Yellowfin All-In-One"

# Install OS applications required for application installation
RUN apk add unzip gzip tar gzip curl sed sudo openjdk8-jre ttf-dejavu postgresql

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

# Prepare PostgreSQL and Yellowfin filesystem directories
RUN mkdir /run/postgresdata && chmod g+s /run/postgresdata/ && chown -R postgres /run/postgresdata \
&& mkdir /run/postgresql && chmod g+s /run/postgresql && chown -R postgres /run/postgresql \
&& mkdir /opt && mkdir /opt/yellowfin && chmod a+w /opt/yellowfin

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
&& echo DatabaseDBAUser=postgres >> /tmp/silent-install.properties \
&& echo DatabaseDBAPassword=yellowfin >> /tmp/silent-install.properties \
&& echo DatabaseUser=postgres >> /tmp/silent-install.properties \
&& echo DatabasePassword=yellowfin >> /tmp/silent-install.properties \
&& cat /tmp/silent-install.properties

# Start Postgres, Execute Installer and stop Postgres in single step
RUN echo "Initializing PostgreSQL" && sudo -u postgres initdb -D /run/postgresdata \
&& echo "Starting PostgreSQL" && sudo -u postgres pg_ctl -D /run/postgresdata/ -w start \
&& echo "Installing Yellowfin" && java -jar /tmp/yellowfin.jar -silent /tmp/silent-install.properties \
&& echo "Stopping PostgreSQL" && sudo -u postgres pg_ctl -D /run/postgresdata/ -w stop

# Mark management scripts as executable
RUN chmod +x /opt/yellowfin/appserver/bin/catalina.sh /opt/yellowfin/appserver/bin/startup.sh /opt/yellowfin/appserver/bin/shutdown.sh

#######################################################################################################
# Prepare Yellowfin Launcher
#
# Create docker entry file, and mark file as docker entry-point
#######################################################################################################

# Create docker-entry file, that starts PostgreSQL and then Yellowfin
RUN echo sudo -u postgres pg_ctl -D /run/postgresdata/ -w start > /opt/docker-entry.sh \
&& echo "echo Over-ride Memory: \$APP_MEMORY" >> /opt/docker-entry.sh \
&& echo "if [[ ! -z \"\${APP_MEMORY}\" ]]; then " >> /opt/docker-entry.sh \
&& echo " sed -i 's/-Xmx2048m/-Xmx'\"\$APP_MEMORY\"'m/g' /opt/yellowfin/appserver/bin/catalina.sh " >> /opt/docker-entry.sh \
&& echo fi  >> /opt/docker-entry.sh \
&& echo /opt/yellowfin/appserver/bin/catalina.sh run >> /opt/docker-entry.sh


ENTRYPOINT ["/bin/sh", "/opt/docker-entry.sh"]
