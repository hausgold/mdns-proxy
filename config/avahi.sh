#!/bin/bash

# Disable the rlimits from default debian
sed \
  -e 's/^\(rlimit\)/#\1/g' \
  -i /etc/avahi/avahi-daemon.conf

# If a avahi daemon is running, kill it
avahi-daemon -c && avahi-daemon -k

# Clean up orphans
rm -rf /run/avahi-daemon/{pid,socket}

# Start avahi
exec avahi-daemon --no-rlimits
