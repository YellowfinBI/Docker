Yellowfin All-In-One Image
=========================

The Yellowfin All-In-One image contains the Yellowfin application and repository database. This can be used for short trials and demonstrations. This image will not persist data outside of the docker container, and all content will be lost when the container is shutdown. This docker image cannot be used in a clustered environment.


Prerequisites
--------------

A Docker installation is required to run the Yellowfin docker containers.
Please see the official [Docker installation guides](https://docs.docker.com/install)


Starting the All-In-One Image
--------------------

```bash
docker run -p 80:8080 yellowfinbi/yellowfin-all-in-one
```

This will start the Yellowfin All-In-One image with the default settings and expose Yellowfin on port 80 on the host.

License Deployment
----------------------

The All-In-One deployment will require that a license file be loaded into the web interface after startup.


Configuration Options
----------------------

| Configuration Item | Description | Example |
| ---------------------- | -------------- | ------- |
| Application Memory | Specify the number of megabytes of memory to be assigned to the Yellowfin application. If unset, Yellowfin will use the Java default (usually 25% of System RAM)  |  ```-e APP_MEMORY=4096 ``` |

Where is Data Stored?
----------------------

With the All-In-One image, Yellowfin data/content is stored in the docker container itself. Terminating the container will result in data loss.


After Starting the Container
-----------------------------

After starting a container, use a browser to connect to the docker host's TCP port that has been mapped container's application port.

For example:
```bash
docker run -p 9090:8080 yellowfinbi/yellowfin-all-in-one
```

Connect to:

http://dockerhost:9090


There may be a slight delay before the browser responds after the docker container is started.


Upgrading Yellowfin
--------------------

The Yellowfin All-In-One does not have an upgrade path. Recreating the image will download the latest published Yellowfin installer.


Diagnosing Potential Issues and Modifying Configuration
--------------------------------------------------------

You can connect to a running instance of Yellowfin with the exec command.
This allows you to access log files and system settings.

```bash
docker exec -it <docker containerid> /bin/sh
```

The docker containerid can be obtained from the command:

```bash
docker container list
```

If settings are changed in a running docker container, Yellowfin may require restarting. This can be done with the command:

```bash
docker restart <docker containerid>
```
