#!/bin/bash

# Container name
CONTAINER_NAME=filestoragesystem-nextcloud-1

# Total number of users to delete
NUMBER_OF_USERS=50  # Adjust this if the range changes

echo "Starting user deletion process..."

# Loop through user indices
for i in $(seq 1 $NUMBER_OF_USERS); do
  USERNAME="test_user$i"

  echo "Deleting user: $USERNAME"
  docker exec --user www-data "$CONTAINER_NAME" php occ user:delete "$USERNAME"
done

echo "User deletion process completed."
