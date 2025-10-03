#!/bin/bash
GENMON_ID=11
LAST_REFRESH=0
COOLDOWN=1  # minimum seconds between refreshes

refresh_genmon() {
    local now=$(date +%s)
    if (( now - LAST_REFRESH >= COOLDOWN )); then
        xfce4-panel --plugin-event=genmon-$GENMON_ID:refresh:bool:true
        LAST_REFRESH=$now
    fi
}

refresh_genmon

dbus-monitor --profile "type='signal',sender='org.mpris.MediaPlayer2.spotify'" \
"type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" \
"type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.mpris.MediaPlayer2.spotify'" |
while read -r line; do
    if [[ $line == *"PropertiesChanged"* ]] || [[ $line == *"NameOwnerChanged"* ]]; then
        refresh_genmon
    fi
done