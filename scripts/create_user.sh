#!/bin/bash

CONTAINER_NAME=filestoragesystem-nextcloud-1
SPACE_QUOTA="4G"
GROUP="Users"
NUMBER_OF_USERS=100

for i in $(seq 1 $NUMBER_OF_USERS); do
  USERNAME="test_user$i"
  DISPLAYNAME="TestUser $i"
  USER_PASSWORD="Test_password${i}!"

  # Create the user 
  docker exec -e OC_PASS="$USER_PASSWORD" --user www-data $CONTAINER_NAME \
    php /var/www/html/occ user:add \
    --password-from-env --group="$GROUP" --display-name="$DISPLAYNAME" "$USERNAME"

  # Set the quota for the user
  docker exec --user www-data $CONTAINER_NAME \
    php /var/www/html/occ user:setting "$USERNAME" files quota "$SPACE_QUOTA"
  
done

echo "User creation process completed."

