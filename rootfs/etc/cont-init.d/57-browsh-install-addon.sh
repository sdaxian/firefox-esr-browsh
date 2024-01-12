#!/bin/sh

for file in $(ls /config/profile/extensions/)
do 
    name="$(unzip -p "/config/profile/extensions/$file" manifest.json | jq -r .name)"
    if [ "$name" = "Browsh" ]; then
        echo "browsh need addon is exist"
        exit 0
    fi
done

if [ ! -d "/config/profile/extensions" ]; then
    mkdir -p /config/profile/extensions
fi
cp /app/data/browsh/.config/firefox/profile/extensions/* /config/profile/extensions/
cp /app/data/browsh/.config/firefox/profile/extensions.json /config/profile/extensions.json

