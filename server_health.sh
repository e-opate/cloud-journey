# Defining the log file with a dynamic timestamp
LOG_DIR="$HOME/cloud-journey/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/health_report_$(date +%Y%m%d_%H%M%S).log"

echo "==========================================" >> "$LOG_FILE"
echo " SERVER HEALTH AUDIT: $(date)" >> "$LOG_FILE"
echo "==========================================" >> "$LOG_FILE"

# 1. Checks Disk Space Usage 
echo -e "\n[1. DISK SPACE USAGE]" >> "$LOG_FILE"
df -h / >> "$LOG_FILE"

# 2. Checks Memory Usage
# -m flag displays memory in Megabytes
echo -e "\n[2. MEMORY USAGE]" >> "$LOG_FILE"
free -m >> "$LOG_FILE"

# 3. Checks Network Connections on Ports
echo -e "\n[3. ACTIVE NETWORK SOCKETS]" >> "$LOG_FILE"
ss -tulpn >> "$LOG_FILE"

echo -e "\nAudit complete. Log saved to: $LOG_FILE"
