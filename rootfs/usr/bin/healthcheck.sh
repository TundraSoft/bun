#!/bin/sh

# Docker HEALTHCHECK: exit 0 if the s6 'bun' service is up, 1 if it is down.
SERVICE=$(/package/admin/s6/command/s6-svstat /run/s6-rc/servicedirs/bun)

if echo "$SERVICE" | grep -q "down"; then
  echo "$SERVICE"
  exit 1
else
  echo "$SERVICE"
  exit 0
fi
