
#!/bin/sh

COMPLETION_FILE=/opt/yellowfin/appserver/bin/docker_configuration_done
if test -f "$COMPLETION_FILE"; then
    echo "Docker Configuration Error: $COMPLETION_FILE already exists, exiting"
else

################################################
# Configuration changes to catalina.sh
################################################

# Replace ${installer.appname} Options with ""
sed -i 's/${installer.appname} Options//g' /opt/yellowfin/appserver/bin/catalina.sh

# Replace JAVA_HOME="${JDKPath}" with ""
sed -i 's/JAVA_HOME="${JDKPath}"/#JAVA_HOME=Removed For Docker/g' /opt/yellowfin/appserver/bin/catalina.sh

# Replace CATALINA_HOME="${INSTALL_PATH} with "CATALINA_HOME="/opt/yellowfin/appserver"
sed -i 's/CATALINA_HOME="${INSTALL_PATH}\/appserver"/CATALINA_HOME="\/opt\/yellowfin\/appserver"/g' /opt/yellowfin/appserver/bin/catalina.sh

# Use Default Java Memory allocation, or set to the value of $APP_MEMORY
if [ ! -z "${APP_MEMORY}" ]; then
  # Replace JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx{APP_MEMORY}m
  sed -i 's/-Xmx${installer.app-server-memory}m/-Xmx'"$APP_MEMORY"'m/g' /opt/yellowfin/appserver/bin/catalina.sh
else
  # Replace JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx${installer.app-server-memory}m" with "JAVA_OPTS="$JAVA_OPTS -Xms128m"
  sed -i 's/-Xmx${installer.app-server-memory}m//g' /opt/yellowfin/appserver/bin/catalina.sh
fi

#Add JGroups Options under existing memory options
sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djgroups.receive_on_all_interfaces=true"/g' /opt/yellowfin/appserver/bin/catalina.sh

#Add External JGroups Address
if [ ! -z "${CLUSTER_ADDRESS}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.external_addr='"$CLUSTER_ADDRESS"'"/g' /opt/yellowfin/appserver/bin/catalina.sh
fi

if [ ! -z "${CLUSTER_PORT}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.external_port='"$CLUSTER_PORT"'"/g' /opt/yellowfin/appserver/bin/catalina.sh
fi

if [ ! -z "${CLUSTER_INTERFACE}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.bind_addr='"$CLUSTER_INTERFACE"'"/g' /opt/yellowfin/appserver/bin/catalina.sh
else
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.bind_addr=match-interface:eth0"/g' /opt/yellowfin/appserver/bin/catalina.sh
fi


################################################
# Configuration changes to web.xml
################################################

# Replace ${installer.webapp.url} with "/opt/yellowfin/appserver/webapps/ROOT"
sed -i 's/${installer.webapp.url}/\/opt\/yellowfin\/appserver\/webapps\/ROOT/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${installer.additional.bof.settings} with ""
sed -i 's/${installer.additional.bof.settings}//g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace <param-value>${installer.appname} Connection Pool</param-value> with "<param-value>Connection Pool</param-value>"
sed -i 's/<param-value>${installer.appname} Connection Pool<\/param-value>/<param-value>Connection Pool<\/param-value>/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${welcome.file} with $WELCOME_PAGE or index_mi.jsp
if [ -z "${WELCOME_PAGE}" ]; then
  sed -i 's/${welcome.file}/index_mi.jsp/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@${welcome.file}@'"$WELCOME_PAGE"'@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Replace ${jdbc-class-name} with environment variable $JDBC_CLASS_NAME
sed -i 's/${jdbc-class-name}/'"$JDBC_CLASS_NAME"'/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${jdbc-conn-url} with environment variable $JDBC_CONN_URL
sed -i 's@${jdbc-conn-url}@'"$JDBC_CONN_URL"'@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-userid} with environment variable $JDBC_CONN_USER
sed -i 's/${config-user-userid}/'"$JDBC_CONN_USER"'/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-passwd} with environment variable $JDBC_CONN_PASS
sed -i 's/${config-user-passwd}/'"$JDBC_CONN_PASS"'/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-passwd-encryption} with environment variable $JDBC_CONN_ENCRYPTED
if [ -z "${JDBC_CONN_ENCRYPTED}" ]; then
  sed -i 's/${config-user-passwd-encryption}/false/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's/${config-user-passwd-encryption}/'"$JDBC_CONN_ENCRYPTED"'/g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Replace <param-value>25</param-value> with <param-value>$JDBC_MAX_COUNT</param-value>
if [ ! -z "${JDBC_MAX_COUNT}" ]; then
  sed -i 's@<param-value>25</param-value>@<param-value>'"$JDBC_MAX_COUNT"'</param-value>@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
fi


#
#   Insert Cluster Management Servlet
#
# <!-- Cluster Management -->
#<servlet>
#       <servlet-name>ClusterManagement</servlet-name>
#       <servlet-class>com.hof.mi.servlet.ClusterManagement</servlet-class>
#       <init-param>
#             <param-name>ClusterType</param-name>
#             <param-value>REPOSITORY</param-value>
#       </init-param>
#       <init-param>
#             <param-name>SerialiseWebserviceSessions</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>CheckSumRows</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>EncryptSessionId</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>EncryptSessionData</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>AutoTaskDelegation</param-name>
#             <param-value>true</param-value>
#       </init-param>
#		<init-param>
#              <param-name>TaskTypes</param-name>
#              <param-value>
#                     REPORT_BROADCAST_BROADCASTTASK,
#                     REPORT_BROADCAST_MIREPORTTASK,
#                     FILTER_CACHE,
#                     SOURCE_FILTER_REFRESH,
#                     SOURCE_FILTER_UPDATE_REMINDER,
#                     THIRD_PARTY_AUTORUN,
#                     ORGREF_CODE_REFRESH,
#                     ETL_PROCESS_TASK,
#                     SIGNALS_DCR_TASK,
#                     SIGNALS_ANALYSIS_TASK,
#                     SIGNALS_CLEANUP_TASK,
#                     COMPOSITE_VIEW_REFRESH,
#                     SIGNALS_CORRELATION_TASK
#              </param-value>
#       </init-param>
#       <init-param> 
#              <param-name>MaxParallelTaskCounts</param-name> 
#              <param-value>
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2
#              </param-value>
#       </init-param> 
#       <load-on-startup>11</load-on-startup>
# </servlet>

# Replace <!-- Web Services Servlet --> with Cluster Management XML
sed -i 's@<!-- Web Services Servlet -->@<servlet>\n       <servlet-name>ClusterManagement</servlet-name>\n       <servlet-class>com.hof.mi.servlet.ClusterManagement</servlet-class>\n       <init-param>\n             <param-name>ClusterType</param-name>\n             <param-value>REPOSITORY</param-value>\n       </init-param>\n       <init-param>\n             <param-name>SerialiseWebserviceSessions</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>CheckSumRows</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>EncryptSessionId</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>EncryptSessionData</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>AutoTaskDelegation</param-name>\n             <param-value>true</param-value>\n       </init-param>\n      <load-on-startup>11</load-on-startup>\n   </servlet>\n\n<!-- Web Services Servlet -->@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml


# Add TaskTypes with environment variable $NODE_BACKGROUND_TASKS, or inserts the default
if [ -z "${NODE_BACKGROUND_TASKS}" ]; then
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>TaskTypes</param-name>\n             <param-value>\nREPORT_BROADCAST_BROADCASTTASK,\nREPORT_BROADCAST_MIREPORTTASK,\nFILTER_CACHE,\nSOURCE_FILTER_REFRESH,\nSOURCE_FILTER_UPDATE_REMINDER,\nTHIRD_PARTY_AUTORUN,\nORGREF_CODE_REFRESH,\nETL_PROCESS_TASK,\nSIGNALS_DCR_TASK,\nSIGNALS_ANALYSIS_TASK,\nSIGNALS_CLEANUP_TASK,\nCOMPOSITE_VIEW_REFRESH,\nSIGNALS_CORRELATION_TASK\n             </param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>TaskTypes</param-name>\n             <param-value>'"$NODE_BACKGROUND_TASKS"'</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Add MaxParallelTaskCounts with environment variable $NODE_PARALLEL_TASKS, or inserts the default
if [ -z "${NODE_PARALLEL_TASKS}" ]; then
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>MaxParallelTaskCounts</param-name>\n             <param-value>2,2,2,2,2,2,2,2,2,2,2,2,2</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>MaxParallelTaskCounts</param-name>\n             <param-value>'"$NODE_PARALLEL_TASKS"'</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml
fi


################################################
# Configuration changes to server.xml
################################################

# Replace ${app-server-port} with environment variable $APP_SERVER_PORT
if [ -z "${APP_SERVER_PORT}" ]; then
  sed -i 's/${app-server-port}/8080/g' /opt/yellowfin/appserver/conf/server.xml
else
  sed -i 's/${app-server-port}/'"$APP_SERVER_PORT"'/g' /opt/yellowfin/appserver/conf/server.xml
fi

# Replace ${app-server-shutdown-port} with environment variable $APP_SHUTDOWN_PORT
if [ -z "${APP_SHUTDOWN_PORT}" ]; then
  sed -i 's/${app-server-shutdown-port}/8083/g' /opt/yellowfin/appserver/conf/server.xml
else
  sed -i 's/${app-server-shutdown-port}/'"$APP_SHUTDOWN_PORT"'/g' /opt/yellowfin/appserver/conf/server.xml
fi


# Insert Proxy Port with environment variable $PROXY_PORT
if [ ! -z "${PROXY_PORT}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" proxyPort="'"$PROXY_PORT"'"#g' /opt/yellowfin/appserver/conf/server.xml
fi

# Insert Proxy Scheme with environment variable $PROXY_SCHEME
if [ ! -z "${PROXY_SCHEME}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" scheme="'"$PROXY_SCHEME"'"#g' /opt/yellowfin/appserver/conf/server.xml
fi


# Insert Proxy Host with environment variable $PROXY_HOST
if [ ! -z "${PROXY_HOST}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" proxyHost="'"$PROXY_HOST"'"#g' /opt/yellowfin/appserver/conf/server.xml
fi


################################################
# Configuration changes to ROOT.xml
################################################

# Replace ${INSTALL_PATH}/${installer.warfilename} with /opt/yellowfin/appserver/webapps/ROOT
sed -i 's@${INSTALL_PATH}/${installer.warfilename}@/opt/yellowfin/appserver/webapps/ROOT@g' /opt/yellowfin/appserver/conf/Catalina/localhost/ROOT.xml

################################################
# Configuration changes to log4j.properties
################################################


if [ -e "/opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j.properties" ]; then
	# Replace {catalina.home}/ with /opt/yellowfin/appserver
	sed -i 's@${catalina.home}@/opt/yellowfin/appserver@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j.properties
	# Replace ${installer.applogfilename}/ with yellowfin.log
	sed -i 's@${installer.applogfilename}@yellowfin.log@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j.properties
fi

if [ -e "/opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j2.xml" ]; then
	# Replace {catalina.home}/ with /opt/yellowfin/appserver
	sed -i 's@${catalina.home}@/opt/yellowfin/appserver@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j2.xml
	# Replace ${installer.applogfilename}/ with yellowfin.log
	sed -i 's@${installer.applogfilename}@yellowfin.log@g' /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/log4j2.xml
fi

################################################
# Download additional libraries into WEB-INF/lib
################################################

# See if a URL for additional libraries has been passed
if [ ! -z "${LIBRARY_ZIP}" ]; then
  curl -qL $LIBRARY_ZIP -o /opt/yellowfin/appserver/bin/additional_libraries.zip
  unzip /opt/yellowfin/appserver/bin/additional_libraries.zip -d /opt/yellowfin/appserver/webapps/ROOT/WEB-INF/lib
fi

################################################
# Write Completion Flag
################################################

touch /opt/yellowfin/appserver/bin/docker_configuration_done
echo "Docker Configuration Complete"

fi
