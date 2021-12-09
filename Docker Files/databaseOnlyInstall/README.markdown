Yellowfin Database Only Installer
=========================

The Yellowfin Database Only Installation container will perform an installation of Yellowfin into a specified repository database. The container does install the filesystem component within the container, but it is deleted after installation.

Prerequisites
--------------

A Docker installation is required to run the Yellowfin docker containers.
Please see the official [Docker installation guides](https://docs.docker.com/install)


Build Prerequisites
--------------------

This docker image will require the following assets at build time:

| Asset | Description | Location |
| ---------------------- | -------------- | ------- |
| yellowfin-installar.jar  | A Yellowfin Installer renamed to yellowfin-installer.jar (Required) | This file can be sourced from the Yellowfin website |
|ListDatabaseTables.jar  | This JAR file provides a list of tables from the specified database URL (Required) | This file is included with the DockerFile |
| Repository JDBC driver | The JDBC driver to access the repository database. The Dockerfile will need to be updated to reference the correct JDBC and COPY it into the image. This is only required if the driver required to access the Yellowfin Repository is not bundled with Yellowfin. | This file can be sourced from the specific database vendor's website. |

Database Only Installer Container Parameters
----------------------


| Configuration Item | Description | Example |
| ---------------------- | -------------- | ------- |
| Database Type Code, DATABASE_TYPE| Specify the Yellowfin Repository Database Type PostgreSQL/MySQL/Oracle/SQLServer (Required) | ```-e DATABASE_TYPE=PostgreSQL``` |
| Repository Username, DATABASE_USER| Specify the Database User required to access the Repository Database (Required) | ```-e DATABASE_USER=dba``` |
| Repository Password,  DATABASE_PASSWORD | Specify the Database Password required to access the Repository Database. (Required) |  ```-e  DATABASE_PASSWORD=secret``` |
| Repository DBMS Host, DATABASE_HOST| Specify the Database Host where the Repository Database resides  (Required) | ```-e DATABASE_HOST=10.10.10.39 ``` |
| Repository DBMS Port,  DATABASE_PORT | Specify the TCP Port required to access the Repository Database. (Required) |  ```-e  DATABASE_PORT=5432 ``` |
| Repository DBMS Name,  DATABASE_NAME | Specify the Database Name of the Repository Database. This database needs to exist prior to installation  (Required) |  ```-e  DATABASE_NAME=yellowfin``` |



Starting the Yellowfin Database-Only Installer
----------------------

Start the container with the mandatory database connection parameters. 

```bash
docker run -e DATABASE_TYPE=PostgreSQL -e DATABASE_HOST=10.10.10.39 -e DATABASE_PORT=5432 -e DATABASE_NAME=yellowfindocker -e DATABASE_USER=admin -e DATABASE_PASSWORD=admin yellowfin-repository-database-install
```

After Starting the Container
-----------------------------

After starting a container, the application will populate the Yellowfin schema into the given repository database. The installation logs are analyzed after installation. If successful, the container will exist with a zero exit code, otherwise the container will return a negative exit code.

Prior to installation, a process separate from the Yellowfin installer will check the repository database for existing tables. If existing tables are found (namely the existence of ACCESSCLASSLIST table), then the container will exit with a negative exist code.
