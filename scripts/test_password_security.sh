#!/bin/bash

# Container and test values
CONTAINER_NAME=filestoragesystem-nextcloud-1
TEST_USER=testuser
GOOD_PASSWORD='Goskfnb@1dbshad!'
BAD_PASSWORDS=(
  "1awjs@"                # too short
  "nouupercase1!"         # no uppercase
  "NonumberS!"            # no number
  "NoSpecialChars123"     # no special character
)

echo "Removing any existing test user..."
docker exec -u www-data $CONTAINER_NAME php occ user:delete --no-interaction $TEST_USER > /dev/null 2>&1

echo "Creating test user with a good password..."
docker exec -u www-data -e OC_PASS="$GOOD_PASSWORD" $CONTAINER_NAME php occ user:add --password-from-env --display-name="Test User" $TEST_USER

if [ $? -ne 0 ]; then
  echo "Error: Failed to create test user. Aborting."
  exit 1
fi

echo "Test user created."

# Test bad passwords
for pwd in "${BAD_PASSWORDS[@]}"; do
  echo
  echo "Testing bad password: '$pwd'"
  OUTPUT=$(docker exec -u www-data -e OC_PASS="$pwd" $CONTAINER_NAME php occ user:resetpassword --password-from-env $TEST_USER 2>&1)

  if echo "$OUTPUT" | grep -qiE "does not meet the password policy|at least one"; then
    echo "Rejected as expected."
  elif echo "$OUTPUT" | grep -qiE "successfully reset|successfully changed"; then
    echo "NOT rejected — password policy failed."
    echo "$OUTPUT"
  else
    echo "Unclear result:"
    echo "$OUTPUT"
  fi
done

# Test good password
echo
echo "Testing good password: '$GOOD_PASSWORD'"
OUTPUT=$(docker exec -u www-data -e OC_PASS="$GOOD_PASSWORD" $CONTAINER_NAME php occ user:resetpassword --password-from-env $TEST_USER 2>&1)

if echo "$OUTPUT" | grep -qiE "successfully reset|successfully changed"; then
  echo "Accepted as expected."
else
  echo "Rejected unexpectedly."
  echo "$OUTPUT"
fi

# Test login failures 
echo
echo "Simulating failed login attempts to test account lockout..."

LOGIN_ENDPOINT="http://localhost:8080/login"
COOKIE_JAR=$(mktemp)

for i in {1..6}; do
  echo "Login attempt $i with wrong password..."
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$LOGIN_ENDPOINT" \
    -c "$COOKIE_JAR" \
    -d "user=$TEST_USER&password=WrongPassword$i")

  if [ "$RESPONSE" = "303" ]; then
    echo "Attempt $i: Login failed (as expected)"
  else
    echo "Attempt $i: Unexpected response: HTTP $RESPONSE"
  fi
done

echo
echo "Cleaning up test user..."
docker exec -u www-data $CONTAINER_NAME php occ user:delete --no-interaction $TEST_USER > /dev/null 2>&1

echo "Password security tests complete."
