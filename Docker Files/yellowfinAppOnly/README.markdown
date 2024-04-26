Yellowfin Application Only Docker Image
==========================================

The Yellowfin App Only image contains only the Yellowfin application, and can be connected to an existing repository database. This image can be used as a single instance, or as a cluster node.
This can be used in production, data is persisted in the external repository so that no data is lost when containers are shutdown.

#### Other Deployment Options

Modifying the DockerFile allows changes to be made to the image to handle particular custom deployment use-cases. The DockerFile and other assets required for building the Docker image are available on GitHub at https://github.com/YellowfinBI/Docker


Prerequisites
--------------

A Docker installation is required to run the Yellowfin docker containers.
Please see the official [Docker installation guides](https://docs.docker.com/install)

The Application Only image requires that a Yellowfin Repository be pre-installed on an accessible host.

Building the Application Only Image
------------------------------------

The Yellowfin Application Only image requires that a Yellowfin JAR installer be accessible in the current directory at build time.
The Yellowfin JAR installer should be named "yellowfin-installer.jar"

Run this command to create the Yellowfin App Only image.

```bash
sudo docker build . -t yellowfin-app-only
```


Starting the Application Only Image
-------------------------------------


```bash
sudo docker run -d -p 80:8080 \
-e JDBC_CLASS_NAME=org.postgresql.Driver \
-e JDBC_CONN_URL=jdbc:postgresql://dbhost:5432/yellowfinDatabase \
-e JDBC_CONN_USER=dbuser \
-e JDBC_CONN_PASS=dbpassword \
yellowfin-app-only:latest
```

This will start the Yellowfin Application Only image with the default settings and expose Yellowfin on port 80 on the host. The connection details for the external Yellowfin repository database needs to be passed to image. It is assumed that the Yellowfin Repository will be installed with the standard Yellowfin installer prior to starting the Application Only docker container. The JDBC connection settings required for container startup can be obtained from the Yellowfin/appserver/webapps/ROOT/WEB-INF/web.xml file from the instance used to install the database.

If the Yellowfin repository is in a database that requires user supplied JDBC drivers (such as Oracle or MySQL) then these drivers can be added to the Docker container with the LIBRARY_ZIP environmental variable.

License Deployment
----------------------

As an existing Yellowfin Repository database is used for the Yellowfin Application Only image, a license should already be present. If a license is not present, it can be loaded via the web interface after node startup. This will apply a license to all Yellowfin nodes that share the Yellowfin Respository.


Configuration Options
----------------------

Configuration Options can be passed to the docker containers via -e parameter.

| Configuration Item | Description | Example |
| ---------------------- | -------------- | ------- |
| JDBC Driver Name, JDBC_CLASS_NAME| Configure the JDBC Driver Class for connecting to the Yellowfin Repository (Required)|  ```-e JDBC_CLASS_NAME=org.postgresql.Driver ``` |
| Repository URL, JDBC_CONN_URL| Specify the Connection URL to the Repository Database (Required) | ```-e JDBC_CONN_URL=jdbc:postgresql://host:5432/yf``` |
| Repository Username, JDBC_CONN_USER| Specify the Database User required to access the Repository Database (Required) | ```-e JDBC_CONN_USER=dba``` |
| Repository Password, JDBC_CONN_PASS | Specify the Database Password required to access the Repository Database. This can be encrypted. (Required) |  ```-e JDBC_CONN_PASS=secret``` |
| Application Memory, APP_MEMORY | Specify the number of megabytes of memory to be assigned to the Yellowfin application. If unset, Yellowfin will use the Java default (usually 25% of System RAM)  |  ```-e APP_MEMORY=4096 ``` |
| Application Log Verbosity, LOG_LEVEL | Specify the verbosity of the application logs (INFO/DEBUG/ERROR/WARN/TRACE) (Default: INFO)|  ```-e LOG_LEVEL=DEBUG ``` |
| DB Password Encrypted, JDBC_CONN_ENCRYPTED | Specify whether the Database Password is encrypted (true/false) | ```-e JDBC_CONN_ENCRYPTED=true ```|
| Connection Pool Size, JDBC_MAX_COUNT | Specify the maximum size of the Repository Database connection pool. (Default: 25) | ```-e JDBC_MAX_COUNT=25``` |
| Default Welcome Page, WELCOME_PAGE | Specify the default index page.  | ```-e WELCOME_PAGE=custom_index.jsp``` |
| Internal Application HTTP Port, APP_SERVER_PORT | Specify the internal HTTP port. (Default: 8080)| ```-e APP_SERVER_PORT=9090``` |
| Internal Shutdown Port, TCP_PORT | Specify the internal shutdown port. (Default: 8083)| ```-e TCP_PORT=9093``` |
| Proxy Port, PROXY_PORT | External Proxy Port | ```-e PROXY_PORT=443``` |
| Proxy Scheme, PROXY_SCHEME | External Proxy Scheme (http/https) | ```-e PROXY_SCHEME=https``` |
| Proxy Host, PROXY_HOST | External Proxy Host or IP address | ```-e PROXY_HOST=reporting.company.com``` |
| Secure Flag, SECURE_ENABLED | Enable the secure Connector flag (true/false) (Default: false) | ```-e SECURE_ENABLED=true``` |
| Same-Site Cookie Mode, SAMESITE_COOKIE_MODE | Configure Same-Site Cookie behaviour (unset/none/lax/strict) (Default: unset) | ```-e SAMESITE_COOKIE_MODE=none``` |
| External Cluster Address, CLUSTER_ADDRESS | External Cluster Address for Cluster Messaging. Usually the host or IP address of the Docker Host | ```-e CLUSTER_ADDRESS=10.10.10.23``` |
| External Cluster Port, CLUSTER_PORT | A Unique TCP port for this container to receive Cluster Messages from other nodes | ```-e CLUSTER_PORT=7801``` |
| Internal Cluster Network Adapter, CLUSTER_INTERFACE | Specify the docker interface to bind Cluster Messages to. Defaults to eth0, but this may need to be changed for Kubernetes and DockerSwarm | ```-e CLUSTER_INTERFACE=match-interface:eth1``` |
| Background Processing Task Types, NODE_BACKGROUND_TASKS | Comma separated list of which background Task Types can be run on this node. NODE_PARALLEL_TASKS must also be updated if this item is specified. If unspecified, all Task Types will be enabled. | ```-e NODE_BACKGROUND_TASKS=FILTER_CACHE,ETL_PROCESS_TASK``` |
| Background Task Processing Jobs, NODE_PARALLEL_TASKS | Comma separated list of the number of concurrent tasks for each Task Type that can be run on this node. The number of elements passed here must match the number of Task Types passed by NODE_BACKGROUND_TASKS | ```-e NODE_PARALLEL_TASKS=5,4``` |
| Additional Libraries URL, LIBRARY_ZIP | URL to a Zip file that contains additional libraries to be extracted into lib folder of Yellowfin. This can be used to add additional JDBC drivers or custom plugins to Yellowfin. Make sure that the path is not included with zip entries in the archive. | ```-e LIBRARY_ZIP=http://lib-host/libraries.zip ``` |
| Additional Content URL, CONTENT_ZIP | URL to a Zip file that contains additional content to be extracted into ROOT folder of Yellowfin. This can be used to add additional styles, images, JSP files, and libraries to Yellowfin. The Zip file can contain subdirectories, so that content can be delivered into multiple subfolders in the ROOT directory. | ```-e CONTENT_ZIP=http://lib-host/contents.zip ``` |
| Skip OS Package Updates, SKIP_OS_PACKAGE_UPGRADE | Set SKIP_OS_PACKAGE_UPGRADE=TRUE to prevent an operating system package update on container startup | ```-e SKIP_OS_PACKAGE_UPGRADE=TRUE``` |
| Global Session Timeout, SESSION_TIMEOUT | Specify the time in minutes it takes for sessions to expire. (Default: 30) | ```-e SESSION_TIMEOUT=60``` |



Where is Data Stored?
----------------------

Yellowfin data/content is stored in the linked repository database. Terminating the container will not result in data loss.


After Starting the Container
-----------------------------

After starting a container, use a browser to connect to the docker host's TCP port that has been mapped container's application port.

For example:
```bash
sudo docker run -d -p 9090:8080 \
-e JDBC_CLASS_NAME=org.postgresql.Driver \
-e JDBC_CONN_URL=jdbc:postgresql://dbhost:5432/yellowfinDatabase \
-e JDBC_CONN_USER=dbuser \
-e JDBC_CONN_PASS=dbpassword \
yellowfin-app-only:latest
```

Connect to:

http://dockerhost:9090


There may be a slight delay before the browser responds after the docker container is started.


Upgrading Yellowfin
--------------------

The Yellowfin Repository database should be upgraded manually, and a new version of the Yellowfin Application Only container started against the upgraded database. For a Zero-Down-Time upgrade in a clustered environment, existing application nodes can be placed in Read-Only mode, whilst the database is upgraded, and new version application nodes brought online.


Proxy Considerations
----------------------

If the docker container is hosted behind a webserver, loadbalancer, or proxy then the Proxy Host, Proxy Scheme and Proxy Port paramters may need to be used to help Yellowfin generate URLs. These parameters configure the external address and scheme for the Yellowfin application. This configuration is only available for the Yellowfin Application Only docker image.

#### Proxy Host

This is usually the hostname of the proxy that users will connect through to access Yellowfin.

#### Proxy Port

This is the TCP port that users will connect on when accessing Yellowfin via the proxy. This will usually be 80. If an external proxy is enalbing SSL, then this will usually be set to 443.

#### Proxy Scheme

This can be HTTP or HTTPS. Set this to HTTPS if a proxy is enabling SSL security for non-SSL enabled Yellowfin nodes. This is used for generating redirects with the correct scheme for the environment.

#### Secure Flag

Depending on the nature of the proxy, the secure flag may need to be enabled. This allows the application to process requests as if called from a secure end-point.


Same-Site Cookies
----------------------

If content from the Yellowfin environment is to be embedded on external sites with different domains, then changes may need to be made to the Same-Site Cookie configuration. 

Options for SAMESITE_COOKIE_MODE are defined here:

 - If value is __unset__ then the same-site cookie attribute won't be set. This is the default value.

 - If value is __none__ then the same-site cookie attribute will be set and the cookie will always be sent in cross-site requests.

 - If value is __lax__ then the browser only sends the cookie in same-site requests and cross-site top level GET requests.

 - If value is __strict__ then the browser prevents sending the cookie in any cross-site request.

(From: [Apache Tomcat Same-Site Cookie configuration](https://tomcat.apache.org/tomcat-9.0-doc/config/cookie-processor.html))


Clustering Considerations
----------------------

The Yellowfin Application Only docker image has Respository Clustering enabled. This will allow multiple application nodes that share the same Repository Database to register as a cluster member. Each cluster member needs a unique TCP end-point for internode communications, and this will need to be set when the container is started. This can be configured with the CLUSTER_ADDRESS and CLUSTER_PORT configuration parameters.

#### Cluster Address

This will be an address that is resolvable from all docker nodes (which may be running on separate docker hosts). This will usually be set to the hostname or IP address of the docker host. Multiple Yellowfin docker containers running on the same host can share the same Cluster Address, but will need to have a unique TCP port for communication.

#### Cluster Port

This is the TCP port that is exposed to the outside network for internode communication. The port exposed here will also need to be forwarded to the external network with the -p parameter.


#### 3 Node Cluster Example

Running three nodes on a single host requires that external exposed ports do not conflict. This means assigning unique ports for both web access and internode communication across all containers. The internal ports for web access and internode communication are 8080 and 7800 respectively, but using the -p parameter, these should be mapped to non-conflicting ports on the docker host.

Node 1:


```bash
sudo docker run -d -p 81:8080 -p 7801:7800 \
-e JDBC_CLASS_NAME=org.postgresql.Driver \
-e JDBC_CONN_URL=jdbc:postgresql://dbhost:5432/yellowfinDatabase \
-e JDBC_CONN_USER=dbuser \
-e JDBC_CONN_PASS=dbpassword \
-e CLUSTER_ADDRESS=dockerhost1 \
-e CLUSTER_PORT=7801 \
--name yellowfin_node1 \
yellowfin-app-only:latest
```
Configured so that port 81 is the exposed Web UI port, and 7801 is used for Cluster Messaging

Node 2:
```bash
sudo docker run -d -p 82:8080 -p 7802:7800 \
-e JDBC_CLASS_NAME=org.postgresql.Driver \
-e JDBC_CONN_URL=jdbc:postgresql://dbhost:5432/yellowfinDatabase \
-e JDBC_CONN_USER=dbuser \
-e JDBC_CONN_PASS=dbpassword \
-e CLUSTER_ADDRESS=dockerhost1 \
-e CLUSTER_PORT=7802 \
--name yellowfin_node2 \
yellowfin-app-only:latest
```
Configured so that port 82 is the exposed Web UI port, and 7802 is used for Cluster Messaging

Node 3:
```bash
sudo docker run -d -p 83:8080 -p 7803:7800 \
-e JDBC_CLASS_NAME=org.postgresql.Driver \
-e JDBC_CONN_URL=jdbc:postgresql://dbhost:5432/yellowfinDatabase \
-e JDBC_CONN_USER=dbuser \
-e JDBC_CONN_PASS=dbpassword \
-e CLUSTER_ADDRESS=dockerhost1 \
-e CLUSTER_PORT=7803 \
--name yellowfin_node3 \
yellowfin-app-only:latest
```
Configured so that port 83 is the exposed Web UI port, and 7803 is used for Cluster Messaging

The exposed Web UI (HTTP) ports (ports 81, 82 and 83 in the above example), should be mapped to a load balancer, so that web traffic is distributed across the cluster. Clients will connect to a single end-point in their browser to access the Yellowfin instance. For testing purposes, connecting to any of the individual ports will load the Web UI on the corresponding Yellowfin node.

Internode cluster communication will occur on the other exposed ports (7801, 7802 and 7803). The combination of cluster address and port will be registered in the Yellowfin Repository as the unique address for each discovered node.

When all 3 nodes have started, accessing the info_cluster.jsp, should show that the 3 nodes have joined the cluster.

![Cluster Information](ClusterInfo.png)

Diagnosing Potential Issues and Modifying Configuration
--------------------------------------------------------

You can connect to a running instance of Yellowfin with the exec command.
This allows you to access log files and system settings.

```bash
sudo docker exec -it <docker containerid> /bin/sh
```

The docker containerid can be obtained from the command:

```bash
sudo docker container list
```

If settings are changed in a running docker container, Yellowfin may require restarting. This can be done with the command:

```bash
sudo docker restart <docker containerid>
```
