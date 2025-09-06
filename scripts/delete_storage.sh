#!/bin/bash

# Container and user info
CONTAINER_NAME=filestoragesystem-nextcloud-1

read -p "Enter the username whose storage you want to delete: " USERNAME

# Confirm action
read -p "Are you sure you want to delete all storage files for user '$USERNAME'? This cannot be undone. (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo "Deleting all files in /data/$USERNAME/files..."

# Delete user's files from data directory
docker exec -u www-data "$CONTAINER_NAME" sh -c "rm -rf /var/www/html/data/$USERNAME/files/*"

# Optional: also delete trash and versions
# docker exec -u www-data "$CONTAINER_NAME" sh -c "rm -rf /var/www/html/data/$USERNAME/files_trashbin/*"
# docker exec -u www-data "$CONTAINER_NAME" sh -c "rm -rf /var/www/html/data/$USERNAME/versions/*"

echo "Rescanning user file path..."
docker exec -u www-data "$CONTAINER_NAME" php occ files:scan --path="$USERNAME/files"

echo "Storage deletion and rescan complete for user '$USERNAME'."
