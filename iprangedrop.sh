#!/bin/bash
WEBHOOK_URL="" #webhook goes here
#send an embedded message to Discord
send_to_discord() {
    local message="$1"
    local start_ip="$2"
    local end_ip="$3"    
    #message embed color using decimal
    local embed_color=16711680 

    #sends ip ban log to webhook
    curl -H "Content-Type: application/json" -X POST -d '{
        "embeds": [{
            "title": "IP Block Notification",
            "description": "'"${message}"'",
            "color": '"${embed_color}"',
            "fields": [
                {
                    "name": "Blocked IP Range",
                    "value": "'"${start_ip} to ${end_ip}"'",
                    "inline": false
                }
            ]
        }]
    }' $WEBHOOK_URL
}
#ip input
read -p "Enter the base IP address (e.g., 192.168.1.0): " base_ip

# verify correct ip using regex
if [[ ! $base_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid IP address format."
    exit 1
fi

base_prefix=$(echo $base_ip | cut -d '.' -f 1-3)
last_octet=$(echo $base_ip | cut -d '.' -f 4)

# block all ip'ss in the range from base_ip to base_prefix.255
for i in $(seq $last_octet 255); do
    current_ip="$base_prefix.$i"
    iptables -A INPUT -s $current_ip -j DROP
done

log_message="### The following IP range has been blocked (suck shit):"
start_ip="$base_prefix.$last_octet"
end_ip="$base_prefix.255"
send_to_discord "** $log_message **" "** $start_ip **" "** $end_ip **"

# Print confirmation to the console
echo "ips $base_ip to $base_prefix.255 have been dropped."
exit
