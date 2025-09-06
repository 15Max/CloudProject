#!/bin/bash

# Set the container name and prompt for user info
CONTAINER_NAME=filestoragesystem-nextcloud-1

SPACE_QUOTA="4G"

TEST_PASSWORD='Test_password12!'

GROUP="users"


NUMBER_OF_USERS=50  # Change this to create more users

for i in $(seq 1 $NUMBER_OF_USERS); do
  USERNAME="test_user$i"
  DISPLAYNAME="TestUser $i"

  docker exec -e OC_PASS="$TEST_PASSWORD" --user www-data $CONTAINER_NAME /var/www/html/occ user:add --password-from-env --group="$GROUP" --display-name="$DISPLAYNAME" "$USERNAME"

  # set the quota for each user
  docker exec --user www-data $CONTAINER_NAME /var/www/html/occ user:setting "$USERNAME" files quota "$SPACE_QUOTA"
done
echo "User creation process completed."

