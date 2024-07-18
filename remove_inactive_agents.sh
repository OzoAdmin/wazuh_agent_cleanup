
#!/bin/bash

# Settings
OSSEC_BIN_DIR="/var/ossec/bin"
THRESHOLD_DAYS=30
SUMMARY_FILE="/tmp/summary.txt"

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
deleted_agents=()

# Get the list of agents
agents=$($OSSEC_BIN_DIR/agent_control -l | grep 'ID:' | awk -F ', ' '{print $1}' | awk -F ': ' '{print $2}')
total_agents=$(echo "$agents" | wc -l)

# Iterate through each agent and check if it has been inactive for more than THRESHOLD_DAYS
for agent_id in $agents; do
    agent_info=$($OSSEC_BIN_DIR/agent_control -i $agent_id)
    last_seen_timestamp=$(echo "$agent_info" | grep 'Last keep alive' | awk -F ': ' '{print $2}')
    agent_name=$(echo "$agent_info" | grep 'Name' | awk -F ': ' '{print $2}')
    
    if [ -z "$last_seen_timestamp" ]; then
        continue
    fi
    
    if is_inactive "$last_seen_timestamp"; then
        inactive_agents=$((inactive_agents + 1))
        deleted_agents+=("$agent_id;$agent_name;$last_seen_timestamp")
        $OSSEC_BIN_DIR/manage_agents -r $agent_id > /dev/null 2>&1
    fi
done

# Generate summary
{
    echo "Summary:"
    echo "=============================="
    echo "Total number of agents: $total_agents"
    echo "Number of inactive agents: $inactive_agents"
    echo ""
    echo "Deleted agents:"
    echo "ID   | Name                | Last connection"
    echo "---- | ------------------- | -------------------"
    for agent in "${deleted_agents[@]}"; do
        IFS=';' read -r id name last_seen <<< "$agent"
        last_seen_date=$(date -d "@$last_seen" "+%Y-%m-%d %H:%M:%S")
        printf "%-4s | %-19s | %s
" "$id" "$name" "$last_seen_date"
    done
} > "$SUMMARY_FILE"

# Display summary
cat "$SUMMARY_FILE"

# Remove temporary file
rm "$SUMMARY_FILE"
