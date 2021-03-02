#!/bin/bash

HOSTNAME_CMD=$(hostname)
CONTAINER_INSTALL_YF_DB=true
REDIS_HOST=localhost
# This will sleep the start up by a maxmimum of 15s
RANDOM_SLEEP_TIME=$(( ( RANDOM % 15 )  + 1 ))

# Add a random sleep timer in seconds
echo Sleeping for $RANDOM_SLEEP_TIME seconds
sleep $RANDOM_SLEEP_TIME

# Check if a host value has been set in Redis yet
if [ -z $(redis-cli -h $REDIS_HOST get host) ]
 then
  echo "No host set, set to the current container"
  redis-cli -h $REDIS_HOST set host $HOSTNAME_CMD

  # Sleep for a few seconds and check if we're still the container that will process the YF install
  # This is incase 2 containers both end up reaching this part of the if statement, and we want the last
  # one to be the one that installs YF
  ## Sleep for a couple of seconds
  sleep 5
  ## IF REDIS_GET_HOST == HOSTNAME_CMD
  CLI_CHECK=$(redis-cli -h $REDIS_HOST get host)
  if [ "$CLI_CHECK" == "$HOSTNAME_CMD" ]
   then

    echo "Install YF"
    ## Install YF and Repo DB
    ## Once YF install completed, set a flag in Redis to alert other nodes that the YF Repo DB is ready to accept connections
    redis-cli -h $REDIS_HOST set yf-installed true
    # Start YF on this container

   else

    echo "Another container is taking care of the YF install."
    echo "That container is: " $(redis-cli -h $REDIS_HOST get host)
    CONTAINER_INSTALL_YF_DB=false

  fi

 else

 # This container will only install the YF App
 CONTAINER_INSTALL_YF_DB=false

fi

echo "Am I the container to install the YF DB?" $CONTAINER_INSTALL_YF_DB

if [ $CONTAINER_INSTALL_YF_DB = "false" ]
 then
  echo "Host key already set, another container will install the YF DB"
  echo "Host installing YF Repo DB is: "  $(redis-cli -h $REDIS_HOST get host)
  #echo "$REDIS_GET_HOST"
  # Install YF Only, NO DB.
  # use command line option action.nodbaccess

  # Go to sleep for a couple of seconds, perform check if YF DB installed
  # Break out of loop and start YF once DB is ready
  # Continue in loop till YF DB is installe
  while [ -z $(redis-cli -h $REDIS_HOST get yf-installed) ]
   do
   echo "Waiting for the YF DB to be ready - check container" $(redis-cli -h $REDIS_HOST get host) "to see how it's progressing"
   sleep 5
  done
  
  # Start Yellowfin up now that the Repo DB is ready

fi
