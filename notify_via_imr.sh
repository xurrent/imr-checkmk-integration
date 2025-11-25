#!/bin/bash
# Notify via IMR
# This script sends Checkmk notifications to IMR

# Get the webhook URL from CheckMK parameter
IMR_WEBHOOK_URL="$IMR_WEBHOOK"

# Determine notification source and type
if [ -n "$NOTIFY_SERVICEDESC" ]; then
    NOTIFICATION_SOURCE="service"
else
    NOTIFICATION_SOURCE="host"
fi

# Build the JSON payload matching IMR's expected format
JSON_PAYLOAD=$(cat <<EOFINNER
{
  "notification_type": "$NOTIFY_NOTIFICATIONTYPE",
  "notification_source": "$NOTIFICATION_SOURCE",
  "fields": {
    "host_name": "$NOTIFY_HOSTNAME",
    "HOSTDISPLAYNAME": "$NOTIFY_HOSTALIAS",
    "HOSTSTATE": "$NOTIFY_HOSTSTATE",
    "HOSTOUTPUT": "$NOTIFY_HOSTOUTPUT",
    "SERVICEDISPLAYNAME": "$NOTIFY_SERVICEDESC",
    "SERVICESTATE": "$NOTIFY_SERVICESTATE",
    "SERVICEOUTPUT": "$NOTIFY_SERVICEOUTPUT",
    "PROBLEMID": "$NOTIFY_PROBLEMID",
    "LASTPROBLEMID": "$NOTIFY_LASTPROBLEMID",
    "CONTACT_NAME": "$NOTIFY_CONTACTNAME",
    "CONTACT_EMAIL": "$NOTIFY_CONTACTEMAIL",
    "DATE": "$NOTIFY_DATE",
    "SHORTDATETIME": "$NOTIFY_SHORTDATETIME",
    "LONGDATETIME": "$NOTIFY_LONGDATETIME"
  }
}
EOFINNER
)

# Send the notification to IMR
RESPONSE=$(curl -s -w "\n%{http_code}" \
  --header "Content-Type: application/json" \
  --request POST \
  --data "$JSON_PAYLOAD" \
  "$IMR_WEBHOOK_URL" 2>&1)

# Extract HTTP status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

# Log the result
if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "Notification sent successfully to IMR (HTTP $HTTP_CODE)"
    exit 0
else
    echo "Failed to send notification to IMR (HTTP $HTTP_CODE)"
    echo "Response: $BODY"
    exit 1
fi