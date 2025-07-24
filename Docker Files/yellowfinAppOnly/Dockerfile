#######################################################################################################
#
# Yellowfin Application-Server Only Docker File
#
# An image that will create a new application server node, and connect to an existing Yellowfin
# repository database.
#
# Options can be passed to the image on startup with the -e command
#
#  JDBC_CLASS_NAME                  The java class file for the repository database JDBC connection
#
#  JDBC_CONN_URL                    The JDBC connection string for the repository database
#
#  JDBC_CONN_USER                   The JDBC user for the repository database
#
#  JDBC_CONN_PASS                   The JDBC password for the repository database (can be encrypted)
#
#  APP_MEMORY (Optional)			    Set maximum memory for application (in MB). 
#
#  LOG_LEVEL (Optional)   		    Set logfile verbosity. Options: INFO/DEBUG/ERROR/WARN/TRACE
#
#  JDBC_CONN_ENCRYPTED (Optional)   Whether the database password is encrypted or not. Defaults to false
#
#  JDBC_MAX_COUNT (Optional)        Maximum connection pool size for the repository database connection pool. Defaults to 25
#
#  WELCOME_PAGE (Optional)          The default landing page for the application. Defaults to index_mi.jsp
#
#  APP_SERVER_PORT (Optional)       The HTTP port for the application. Defaults to 8080
#
#  APP_SHUTDOWN_PORT (Optional)     The shutdown port for the application. Defaults to 8083
#
#  PROXY_PORT (Optional)			    External proxy port
#
#  PROXY_SCHEME (Optional)          External proxy scheme (http or https)
#
#  PROXY_HOST (Optional)			    External proxy address
#
#  SECURE_ENABLED (Optional)	        Enable secure=true in tomcat connector configuration
#
#  SAMESITE_COOKIE_MODE (Optional)  Set Same-Site cookie mode. Options: unset/none/lax/strict   Default: none
#
#  CLUSTER_ADDRESS (Optional)	    Set cluster communication TCP address for node
# 
#  CLUSTER_PORT (Optional) 	        Set cluster communication TCP port. Unique for this container. 
#
#  CLUSTER_INTERFACE (Optional)     Set cluster communication network interface. Default: eth0
#
#  NODE_BACKGROUND_TASKS (Optional) Define the types of background tasks that can run on this cluster node
#
#  NODE_PARALLEL_TASKS (Optional)   Define the number of parallel task that can run on this cluster node
#
#  LIBRARY_ZIP (Optional)           Deploy additional file assets into the application server library folder from a specific URL
#
#  CONTENT_ZIP (Optional)           Deploy additional file assets into the application server folder structure from a specific URL
#
#  SKIP_OS_PACKAGE_UPGRADE (Optional) Skip operating system package upgrades on node startup
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
LABEL description="Yellowfin Application Only"
ARG TARGETPLATFORM

# Timezone setup
ENV TZ=Etc/GMT

RUN <<EOT
 #Setup OS Packages
 #Apply Timezone
 ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

 #Install OS applications required for application installation and setup Java
 apt-get update -y
 apt-get upgrade -y 
 apt-get install -y unzip tar curl sed fonts-dejavu fontconfig liboss4-salsa-asound2 libglib2.0-0 libpangoft2-1.0-0 -y 
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
#RUN curl -qL https://files.yellowfin.bi/downloads/9.3/yellowfin-9.3.0-20201008-full.jar -o /tmp/yellowfin.jar

# Alternatively copy in an installer that has been included image
# (This will remove the wait time for downloading the installer during image creation)
# Example syntax for copying in an embedded installer:
COPY yellowfin-installer.jar /tmp/yellowfin.jar

#######################################################################################################
# Perform filesystem installation
#
# Extract assets directly from Yellowfin installer JAR onto filesystem.
#######################################################################################################
RUN <<EOT
 #Extract Yellowfin
 mkdir -p /opt/yellowfin /tmp/yftemp /tmp/yftemp2/appserver/webapps/ROOT /opt/yellowfin/appserver/logs
 #Perform application extraction
 unzip /tmp/yellowfin.jar -d /tmp/yftemp  
 unzip /tmp/yftemp/yfres/yellowfin.zip -d /tmp/yftemp2 
 unzip /tmp/yftemp2/yellowfin.war -d /tmp/yftemp2/appserver/webapps/ROOT 
 cp /tmp/yftemp/yfres/jdbc-drivers/* /tmp/yftemp2/appserver/webapps/ROOT/WEB-INF/lib 
 rm /tmp/yftemp2/yellowfin.war && cp -a /tmp/yftemp2/* /opt/yellowfin/ 
 rm -rf /tmp/yftemp /tmp/yftemp2 /tmp/yellowfin.jar
 chmod +x /opt/yellowfin/appserver/bin/catalina.sh /opt/yellowfin/appserver/bin/startup.sh /opt/yellowfin/appserver/bin/shutdown.sh
EOT


#######################################################################################################
# Configuration
#
# Modify Yellowfin's configuration based on parameters passed to the docker container.
#######################################################################################################

COPY perform_docker_configuration.sh /opt/yellowfin/appserver/bin
RUN <<EOT
 chmod +x /opt/yellowfin/appserver/bin/perform_docker_configuration.sh
 sed -i 's/exec "$PRGDIR"\/"$EXECUTABLE" start "$@"/\/opt\/yellowfin\/appserver\/bin\/perform_docker_configuration.sh\nexec "$PRGDIR"\/"$EXECUTABLE" run "$@"/g' /opt/yellowfin/appserver/bin/startup.sh
EOT

#######################################################################################################
# Installation Customization
#
# Copy and configure additional assets for the Yellowfin installation. This could include:
#
# - Providing support for additional databases (by including JDBC drivers)
# - Providing custom styling
# - Providing a custom index page
# - Providing additional plug-ins (third-party sources, analytic functions, formatters etc)
# - Providing a SSL certificate to tomcat
#
#######################################################################################################


# Install additional Yellowfin dependencies, including JDBC Drivers and custom plugins
# Example of downloading drivers at startup time:
# RUN curl -qL "https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-8.0.18.tar.gz" | tar --strip=1 -C /opt/yellowfin/appserver/lib/ -xz mysql-connector-java-8.0.18/mysql-connector-java-8.0.18.jar
# RUN curl -qL "https://jdbc.postgresql.org/download/postgresql-42.2.8.jar" -o /opt/yellowfin/appserver/lib/postgresql-42.2.8.jar

# Example of copying in drivers that are part of the docker image:
# COPY postgresql-42.2.8.jar /opt/yellowfin/appserver/lib/postgresql-42.2.8.jar


#######################################################################################################
# Launch Yellowfin
#
# Start the Yellowfin application.
#######################################################################################################
WORKDIR /opt/yellowfin/appserver/bin
CMD ["/opt/yellowfin/appserver/bin/startup.sh"]
