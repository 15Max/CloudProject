#!/bin/bash

CONTAINER_NAME="filestoragesystem-nextcloud-1"

# Total number of users to clear storage for
NUMBER_OF_USERS=50  

echo "Starting user storage clearing process..."

for i in $(seq 1 $NUMBER_OF_USERS); do
  USERNAME="test_user$i"

  echo "Deleting storage for user: $USERNAME"

  # Delete all user files
  docker exec --user www-data "$CONTAINER_NAME" sh -c "rm -rf /var/www/html/data/$USERNAME/files/*"

  # Clear any cached file data for the user
  docker exec --user www-data "$CONTAINER_NAME" php occ files:scan --path="$USERNAME/files"
done

echo "User storage deletion process completed."