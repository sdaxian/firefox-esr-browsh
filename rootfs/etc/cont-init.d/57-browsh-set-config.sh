#!/bin/sh

if [ -f "/config/xdg/config/browsh/config.toml" ]; then
    echo "browsh config.toml exist in /config/xdg/config/browsh"
    exit 0
fi

if [ ! -d "/config/xdg/config/browsh" ]; then
    mkdir -p /config/xdg/config/browsh
fi

cp /app/data/browsh/.config/browsh/config.toml /config/xdg/config/browsh