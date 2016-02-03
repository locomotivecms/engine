#!/bin/sh
sh -e /etc/init.d/xvfb start
export DISPLAY=:99.0
export TZ=America/Chicago
date
