# Bash Scripting
echo "Starting System Audit...."
sleep 2
echo "User: $USER"
echo "System Hostname: $(hostname)"
echo "Network Info:"
ip addr | grep inet
echo "Audit Complete."
