# Yellowfin Redis Install Helper

## What is this script?
This script is a proof of concept of how you could use a Redis instance to help manage the deployment of a custom Yellowfin Docker Image that installs the Yellowfin application and Repository database at container runtime.

Please note that this script is targeted at multi-instance deployments (like Yellowfin clusters), where without some sort of control mechanism, could run into issues with multiple containers trying to install the Yellowfin Repository database.


## How does it work?
This script is setup to handle multiple Yellowfin containers starting up and coordinates which container should install the Yellowfin Repository database.

It determines which container will install the Yellowfin Repository database via a key-value pair set by the first container that connects to the Redis instance, with some logic added in to handle race conditions.

Once the container that has installed Yellowfin finishes installing the Yellowfin Repository database (which is determined by the installer finishing), it sets a flag on the Redis instance that the other containers are listening for, at which point the other Yellowfin containers can start up the Yellowfin application.