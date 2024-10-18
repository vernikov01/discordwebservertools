#!/bin/bash

#discord webhook URL goes here
WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
# sends log line to Discord webhook
send_to_discord() {
  local log_line="$1"
  local timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

  # payload / content to post to webhook url
  payload=$(jq -n \
    --arg title "Apache Access Log" \
    --arg timestamp "$timestamp" \
    --arg description "$log_line" \
    '{
      "embeds": [
        {
          "title": $title,
          "description": $description,
          "color": 7506394, # A nice shade of green
          "footer": {
            "text": $timestamp
          }
        }
      ]
    }'
  )
  # curl post request to your webhook url
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "$payload" \
       "$WEBHOOK_URL"
}
# tails the Apache access log and processes any new lines
tail -F /var/log/apache2/access.log | while read log_line; do
  send_to_discord "$log_line"
  sleep 1
done
