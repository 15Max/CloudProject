#!/bin/bash

CONTAINER_NAME=filestoragesystem-nextcloud-1

echo "Enabling password_policy"
docker exec -u www-data $CONTAINER_NAME php occ app:enable password_policy

echo "Setting minimum password length to 10"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy minLength --value=10 --type=integer --no-interaction

echo "Requiring uppercase letters and lowercase letters"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy enforceUpperLowerCase --value=true --type=boolean --no-interaction

echo "Requiring numeric characters"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy enforceNumericCharacters --value=true --type=boolean --no-interaction

echo "Requiring special characters"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy enforceSpecialCharacters --value=true --type=boolean --no-interaction

echo "Enabling password expiration after 30 days"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy expiration --value=30 --type=integer --no-interaction

echo "Enabling lockout after 5 failed login attempts"
docker exec -u www-data $CONTAINER_NAME php occ config:app:set password_policy maximumLoginAttempts --value=5 --type=integer --no-interaction

echo
echo "Restarting container to apply settings..."
docker restart $CONTAINER_NAME

echo "Password policy configured successfully."
