# Wazuh Agent Cleanup Script

This Bash script removes inactive Wazuh agents that have not connected for more than a specified threshold of days. It prompts the user for the inactivity threshold (default 30 days), displays a list of inactive agents with their details, and after user confirmation, deletes those agents. Finally, it shows a summary of the deleted agents.

## Features

- Prompts for the number of days to consider agents inactive (default: 30).
- Lists inactive agents with ID, name, and last connection timestamp.
- Requires user confirmation (y/n) before deleting agents.
- Provides a final summary table of deleted agents.
- Helps automate cleanup of inactive agents in Wazuh/OSSEC environments.

## Requirements

- Wazuh installed with `agent_control` and `manage_agents` utilities available.
- Bash shell.

## Usage

1. Copy the script to a file, for example: `remove_inactive_agents.sh`.
2. Make the script executable:
   ```bash
   chmod +x remove_inactive_agents.sh
   ```
3. Run the script:
   ```bash
   ./remove_inactive_agents.sh
   ```

## Configuration

- `OSSEC_BIN_DIR`: Directory where Wazuh binaries are located. Default is `/var/ossec/bin`.
- The script asks for the inactivity threshold (in days) at runtime, defaulting to 30 if no input or invalid input is provided.

## Example Output

After running the script, an example output flow:

```
How many days back to check for inactive agents? (default 30):

Inactive agents found (inactive for more than 30 days):
ID   | Name               | Last connection
-----|--------------------|---------------------
002  | Agent-2            | 2023-06-15 14:25:30
005  | Agent-5            | 2023-05-20 09:14:12

Do you want to delete these agents? (y/n): y

Deleted agents summary:
ID   | Name               | Last connection
-----|--------------------|---------------------
002  | Agent-2            | 2023-06-15 14:25:30
005  | Agent-5            | 2023-05-20 09:14:12

Deletion completed.
```

## Notes

- The script requires sufficient permissions to run the `agent_control` and `manage_agents` commands.
- It only deletes agents after explicit confirmation from the user.
- Makes use of standard Bash utilities and date formatting.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
