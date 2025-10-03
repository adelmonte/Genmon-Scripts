#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, spotify, procps-ng, wmctrl

if pidof spotify &> /dev/null; then
    # Get all metadata in one call
    METADATA=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
        /org/mpris/MediaPlayer2 \
        org.freedesktop.DBus.Properties.Get \
        string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)
    
    readonly ARTIST=$(echo "$METADATA" | awk '/artist/{getline; getline; gsub(/^[^"]*"|"[^"]*$/, ""); print; exit}' | sed 's/&/\&amp;/g')
    readonly TITLE=$(echo "$METADATA" | awk '/title/{getline; gsub(/^[^"]*"|"[^"]*$/, ""); print; exit}' | sed 's/&/\&amp;/g')
    readonly ALBUM=$(echo "$METADATA" | awk '/album/{getline; gsub(/^[^"]*"|"[^"]*$/, ""); print; exit}' | sed 's/&/\&amp;/g')
    
    ARTIST_TITLE="${ARTIST} - ${TITLE}"
    # Proper length handling
    readonly MAX_CHARS=30
    readonly STRING_LENGTH="${#ARTIST_TITLE}"
    readonly CHARS_TO_REMOVE=$(( STRING_LENGTH - MAX_CHARS ))
    [ "${#ARTIST_TITLE}" -gt "${MAX_CHARS}" ] \
        && ARTIST_TITLE="${ARTIST_TITLE:0:-CHARS_TO_REMOVE}…"
    
    # Panel - Green Spotify icon with text
  # INFO="<txt><span foreground='#1DB954' size='11pt'>   </span> ${ARTIST_TITLE} </txt>"
    INFO="<txt><span foreground='#FFFFFF' size='11pt'>   </span> ${ARTIST_TITLE} </txt>"
    INFO+="<txtclick>wmctrl -x -a \"Spotify\"</txtclick>"
    
    # Tooltip
    MORE_INFO="<tool>"
    MORE_INFO+="Artist: ${ARTIST}\n"
    MORE_INFO+="Album: ${ALBUM}\n"
    MORE_INFO+="Title: ${TITLE}"
    MORE_INFO+="</tool>"
else
    # Panel - Green Spotify icon when not playing
#    INFO="<txt><span foreground='#1DB954' size='11pt'>   </span> </txt>"
#    INFO+="<txtclick>spotify</txtclick>"
    
    # Tooltip
    MORE_INFO="<tool>Spotify is not running\nClick to launch</tool>"
fi

echo -e "${INFO}"
echo -e "${MORE_INFO}"
