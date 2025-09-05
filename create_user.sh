#!/bin/bash

# Set the container name and prompt for user info
CONTAINER_NAME=filestoragesystem-nextcloud-1

read -p "Enter new username: " USERNAME
read -p "Enter display name: " DISPLAYNAME
read -s -p "Enter password: " PASSWORD
echo

# Create user
echo "Creating user '$USERNAME' in Nextcloud..."

docker exec -u www-data -e OC_PASS="$PASSWORD" $CONTAINER_NAME \
  php occ user:add --password-from-env --display-name="$DISPLAYNAME" "$USERNAME"

# Check result
if [ $? -eq 0 ]; then
  echo "User '$USERNAME' created successfully."
else
  echo "Failed to create user '$USERNAME'."
fi
