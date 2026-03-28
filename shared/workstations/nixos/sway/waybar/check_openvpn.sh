#!/usr/bin/env bash
# List all active OpenVPN 3 sessions
sessions=$(openvpn3 sessions-list | grep "Config name" | awk -F/ '{print $NF}' | awk '{sub(/\.ovpn.*$/, ""); print $1}')

if [ -z "$sessions" ]; then
    echo "VPN: OFF"
else
    echo "VPN: $sessions"
fi

