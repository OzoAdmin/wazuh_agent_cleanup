
# Wazuh Agent Cleanup Script

This Bash script removes inactive Wazuh agents that have not connected for more than a specified threshold of days. It also generates a summary table showing the total number of agents, the number of inactive agents, and the details of the deleted agents.

## Features

- Removes Wazuh agents that have been inactive for more than the specified threshold of days.
- Provides a summary table with:
  - Total number of agents.
  - Number of inactive agents.
  - ID, name, and last connection time of deleted agents.
- Runs silently without displaying any intermediate messages, but provides a detailed summary at the end.

## Requirements

- Wazuh installed with the `agent_control` and `manage_agents` utilities available.
- Bash shell.

## Usage

1. Copy the script to a file, e.g., `remove_inactive_agents.sh`.
2. Make the script executable:
   \`\`\`bash
   chmod +x remove_inactive_agents.sh
   \`\`\`
3. Run the script:
   \`\`\`bash
   ./remove_inactive_agents.sh
   \`\`\`

## Configuration

- `OSSEC_BIN_DIR`: Directory where Wazuh binaries are located (default: `/var/ossec/bin`).
- `THRESHOLD_DAYS`: Number of days after which an agent is considered inactive (default: `30`).

## Example Output

After running the script, you will see a summary similar to this:

\`\`\`
Summary:
==============================
Total number of agents: 10
Number of inactive agents: 2

Deleted agents:
ID   | Name                | Last connection
---- | ------------------- | -------------------
002  | Agent-2             | 2023-06-15 14:25:30
005  | Agent-5             | 2023-05-20 09:14:12
\`\`\`

## Notes

- The script uses a temporary file to store the summary, which is deleted after displaying the summary.
- Ensure you have the necessary permissions to run `agent_control` and `manage_agents` commands.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
