#!/bin/bash

# Container name
CONTAINER_NAME=filestoragesystem-nextcloud-1

# Prompt for the username to delete
read -p "Enter the username to delete: " USERNAME

# Confirm action
read -p "Are you sure you want to delete user '$USERNAME'? This action is irreversible. (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

# Attempt to delete the user
echo "Deleting user '$USERNAME'..."

docker exec -u www-data $CONTAINER_NAME \
  php occ user:delete --no-interaction "$USERNAME"

# Check result
if [ $? -eq 0 ]; then
  echo "User '$USERNAME' deleted successfully."
else
  echo "Failed to delete user '$USERNAME'."
fi
