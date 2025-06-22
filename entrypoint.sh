#!/bin/bash

# Exit functions
function stop_server() {
        echo "Stopping Server...."
	sudo -u steam tmux send-keys -t 0 "quit" Enter 
} 

# Trap 
trap 'stop_server' TERM

# Set the user ID and group id
usermod -u ${PUID} steam
groupmod -g ${PGID} steam 

# Set the ownership of /data to the steam user
chown -Rf steam:steam /home/steam 

# Install or update server
if [ ! -d /home/steam/insurgency ] || [ "${STEAM_AUTO_UPDATE}" != "false" ]; then
    sudo -u steam /usr/games/steamcmd "+force_install_dir /home/steam/insurgency +login anonymous +app_update ${STEAM_APP} validate +quit"
fi
# Create console log
touch /home/steam/insurgency/insurgency/logs/console.log && chown steam:steam /home/steam/insurgency/insurgency/logs/console.log

# Launch server 
sudo -u steam tmux new-session -d /home/steam/insurgency/srcds_run -game insurgency -norestart -consolelog /home/steam/insurgency/insurgency/logs/console.log ${SERVER_ADDITIONAL_PARAMS}

# Tail console log to output
tail -f -n +1 /home/steam/insurgency/insurgency/logs/console.log & 

# Wait at least 30 seconds
sleep 30

# Loop in sleep - we have to do this so that the traps work
while [ "$(pgrep srcds_linux | wc -l)" -gt 0 ]; do
	sleep 1
done 

# Exit
exit 0 
