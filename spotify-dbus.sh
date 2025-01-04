#!/bin/bash
GENMON_ID=4

refresh_genmon() {
    xfce4-panel --plugin-event=genmon-$GENMON_ID:refresh:bool:true
}

# Initial refresh when script starts
refresh_genmon

# Monitor both metadata changes and dbus name changes
dbus-monitor --profile "type='signal',sender='org.mpris.MediaPlayer2.spotify'" \
"type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" \
"type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.mpris.MediaPlayer2.spotify'" |
while read -r line; do
    if [[ $line == *"PropertiesChanged"* ]] || [[ $line == *"NameOwnerChanged"* ]]; then
        refresh_genmon
    fi
done
