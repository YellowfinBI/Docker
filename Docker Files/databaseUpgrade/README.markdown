Yellowfin Database Only Upgrader
=========================

The Yellowfin Database Only Upgrader container will perform an upgrade of a Yellowfin repository database. This runs the standard upgrader in database-only mode.

Prerequisites
--------------

A Docker installation is required to run the Yellowfin docker containers.
Please see the official [Docker installation guides](https://docs.docker.com/install)


Build Prerequisites
--------------------

This docker image will require the following assets at build time:

| Asset | Description | Location |
| ---------------------- | -------------- | ------- |
| yellowfin-updater.jar  | A Yellowfin Upgrader renamed to yellowfin-updater.jar (Required) | This file can be sourced from the Yellowfin website |
| Repository JDBC driver | The JDBC driver to access the repository database. The Dockerfile will need to be updated to reference the correct JDBC and COPY it into the image. This is only required if the driver required to access the Yellowfin Repository is not bundled with Yellowfin. | This file can be sourced from the specific database vendor's website. |

Database Only Installer Container Parameters
----------------------

| Configuration Item | Description | Example |
| ---------------------- | -------------- | ------- |
| Repository URL, JDBC_CONN_URL| Specify the Connection URL to the Repository Database (Required) | ```-e DATABASE_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95r``` |
| Repository Username, DATABASE_USER| Specify the Database User required to access the Repository Database (Required) | ```-e DATABASE_USER=dba``` |
| Repository Password,  DATABASE_PASSWORD | Specify the Database Password required to access the Repository Database. (Required) |  ```-e  DATABASE_PASSWORD=secret``` |


Starting the Database Only Upgrader
----------------------

Start the container with the mandatory database connection parameters. 

```bash
docker run -e DATABASE_URL=jdbc:sqlserver://;serverName=localhost;databaseName=yellowfin95rc -e DATABASE_USER=sa -e DATABASE_PASSWORD=password yellowfin-repository-database-upgrade
```

After Starting the Container
-----------------------------

After starting a container, the application will run the database only upgrader against the specified repository.

The upgrade logs are analyzed after the upgrade is finished. If successful, the container will exist with a zero exit code, otherwise the container will return a negative exit code.
