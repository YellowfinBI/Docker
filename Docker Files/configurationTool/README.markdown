Yellowfin Configuration Tool
=========================

The Yellowfin Configuration Tool is an application for applying database configuration items to an existing Yellowfin repository.
The application will push items into the Configuration table in the Yellowfin Repository.
This tool can be used to push in custom configuration into a freshly installed instance of Yellowfin.

Prerequisites
--------------

A Docker installation is required to run the Yellowfin docker containers.
Please see the official [Docker installation guides](https://docs.docker.com/install)


Build Prerequisites
--------------------

This docker image will require the following assets at build time:

| Asset | Description | Location |
| ---------------------- | -------------- | ------- |
| i4-core.jar  | A core library of Yellowfin. This contains the Java application that is used to update the Yellowfin configuration. | This file can be sourced from the Yellowfin/appserver/webapps/ROOT/WEB-INF/lib folder in a Yellowfin installation |
| Repository JDBC driver | The JDBC driver to access the repository database. The Dockerfile will need to be updated to reference the correct JDBC and COPY it into the image. | This file can be sourced from the Yellowfin/appserver/webapps/ROOT/WEB-INF/lib folder in a Yellowfin installation

Configuration Tool Container Parameters
----------------------

| Configuration Item | Description | Example |
| ---------------------- | -------------- | ------- |
| Repository URL, JDBC_CONN_URL| Specify the Connection URL to the Repository Database (Required) | ```-e JDBC_CONN_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95r``` |
| Repository Username, DATABASE_USER| Specify the Database User required to access the Repository Database (Required) | ```-e DATABASE_USER=dba``` |
| Repository Password,  DATABASE_PASSWORD | Specify the Database Password required to access the Repository Database. This can be encrypted. (Required) |  ```-e  DATABASE_PASSWORD=secret``` |
| Configuration Item, CONFIG_<CODE> | Specify the value of a Configuration Item. <CODE> represents a configuration code in the Configuration table of the Yellowfin Repository  |  ```-e CONFIG_SMTP=localhost ``` |
| Plugin Configuration Item, BOF_<CODE> | Specify the value of a BOF Item. <CODE> represents a configuration BOF code which is specified in the web.xml file  |  ```-e BOF_com.hof.interfaces.EventCreation=com.hof.interfaces.DummyEventCreation ``` |


Starting the Configuration Tool
----------------------

Start the container with the mandatory database connection parameters. Any number of configuration items can be passed to the container to be inserted into the specified Yellowfin Repository database.

```bash
docker run -e DATABASE_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95rc -e DATABASE_USER=sa -e DATABASE_PASSWORD=password yellowfin-repository-database-upgrade 
	-e CONFIG_EXTERNALURL=http://10.10.10.39:9090 -e BOF_com.hof.interfaces.EventCreation=com.hof.interfaces.DummyEventCreation yellowfin-configuration-tool

```

After Starting the Container
-----------------------------

After starting a container, the application will make configuration changes to the specified Yellowfin Repository.
The container will exit after the configuration changes have been made.
