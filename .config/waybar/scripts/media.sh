#!/bin/bash

STATUS=$(playerctl status 2>/dev/null)
if [ "$STATUS" = "Playing" ]; then
    playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null | cut -c1-40
fi
