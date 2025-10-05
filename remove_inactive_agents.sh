#!/bin/bash

# Settings
OSSEC_BIN_DIR="/var/ossec/bin"
DEFAULT_THRESHOLD_DAYS=30

# Ask user for the inactivity threshold
read -p "How many days back to check for inactive agents? (default $DEFAULT_THRESHOLD_DAYS): " input_days
if [[ -z "$input_days" ]]; then
    THRESHOLD_DAYS=$DEFAULT_THRESHOLD_DAYS
else
    # Validate input is a positive integer
    if ! [[ "$input_days" =~ ^[0-9]+$ ]] ; then
       echo "Invalid input, using default $DEFAULT_THRESHOLD_DAYS days."
       THRESHOLD_DAYS=$DEFAULT_THRESHOLD_DAYS
    else
       THRESHOLD_DAYS=$input_days
    fi
fi

# Function to check if an agent has been inactive for more than THRESHOLD_DAYS
is_inactive() {
    local last_seen_timestamp=$1
    local current_timestamp=$(date +%s)
    local diff_days=$(( (current_timestamp - last_seen_timestamp) / (60*60*24) ))
    if (( diff_days > THRESHOLD_DAYS )); then
        return 0
    else
        return 1
    fi
}

# Initialize variables
total_agents=0
inactive_agents=0
inactive_list=()
deleted_list=()

# Get the list of agents
agents=$($OSSEC_BIN_DIR/agent_control -l | grep 'ID:' | awk -F ', ' '{print $1}' | awk -F ': ' '{print $2}')
total_agents=$(echo "$agents" | wc -l)

# Collect inactive agents
for agent_id in $agents; do
    agent_info=$($OSSEC_BIN_DIR/agent_control -i $agent_id)
    last_seen_timestamp=$(echo "$agent_info" | grep 'Last keep alive' | awk -F ': ' '{print $2}')
    agent_name=$(echo "$agent_info" | grep 'Name' | awk -F ': ' '{print $2}')

    if [ -z "$last_seen_timestamp" ]; then
        continue
    fi

    if is_inactive "$last_seen_timestamp"; then
        inactive_agents=$((inactive_agents + 1))
        inactive_list+=("$agent_id;$agent_name;$last_seen_timestamp")
    fi
done

# Show summary of inactive agents
echo "Inactive agents found (inactive for more than $THRESHOLD_DAYS days):"
echo "ID   | Name               | Last connection"
echo "-----|--------------------|---------------------"
for agent in "${inactive_list[@]}"; do
    IFS=';' read -r id name last_seen <<< "$agent"
    last_seen_date=$(date -d "@$last_seen" "+%Y-%m-%d %H:%M:%S")
    printf "%-5s | %-18s | %s\n" "$id" "$name" "$last_seen_date"
done

if [ $inactive_agents -eq 0 ]; then
    echo "No inactive agents to remove."
    exit 0
fi

# Ask for confirmation (y/n)
while true; do
    read -p "Do you want to delete these agents? (y/n): " confirm
    case $confirm in
        [Yy])
            # Remove inactive agents and collect deleted info
            for agent in "${inactive_list[@]}"; do
                IFS=';' read -r id name last_seen <<< "$agent"
                $OSSEC_BIN_DIR/manage_agents -r $id > /dev/null 2>&1
                deleted_list+=("$id;$name;$last_seen")
            done
            echo -e "\nDeleted agents summary:"
            echo "ID   | Name               | Last connection"
            echo "-----|--------------------|---------------------"
            for agent in "${deleted_list[@]}"; do
                IFS=';' read -r id name last_seen <<< "$agent"
                last_seen_date=$(date -d "@$last_seen" "+%Y-%m-%d %H:%M:%S")
                printf "%-5s | %-18s | %s\n" "$id" "$name" "$last_seen_date"
            done
            echo "Deletion completed."
            break
            ;;
        [Nn])
            echo "Aborting deletion."
            exit 0
            ;;
        *)
            echo "Please enter y or n."
            ;;
    esac
done
