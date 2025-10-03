#!/usr/bin/env bash
# Dependencies: bash>=4.0, acpi (minimal usage)

# Makes the script more portable
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Battery path
readonly BAT_PATH="/sys/class/power_supply/BAT0"

# Read all battery info in one go to minimize file I/O
read -r MANUFACTURER < "${BAT_PATH}/manufacturer"
read -r MODEL < "${BAT_PATH}/model_name"
read -r SERIAL_NUMBER < "${BAT_PATH}/serial_number"
read -r TECHNOLOGY < "${BAT_PATH}/technology"
read -r TYPE < "${BAT_PATH}/type"
read -r ENERGY_FULL_RAW < "${BAT_PATH}/energy_full"
read -r ENERGY_DESIGN_RAW < "${BAT_PATH}/energy_full_design"
read -r ENERGY_RAW < "${BAT_PATH}/energy_now"
read -r VOLTAGE_RAW < "${BAT_PATH}/voltage_now"
read -r RATE_RAW < "${BAT_PATH}/power_now"
read -r STATUS < "${BAT_PATH}/status"
read -r CAPACITY < "${BAT_PATH}/capacity"

# Convert to human-readable values using bash arithmetic
readonly ENERGY_FULL=$((ENERGY_FULL_RAW / 1000000))
readonly ENERGY_DESIGN=$((ENERGY_DESIGN_RAW / 1000000))
readonly ENERGY=$((ENERGY_RAW / 1000000))
readonly VOLTAGE=$((VOLTAGE_RAW / 1000000))
readonly RATE=$((RATE_RAW / 1000000))

# Get temperature (still need acpi for this)
readonly TEMPERATURE=$(acpi -t 2>/dev/null | cut -d' ' -f4)

readonly CHARGING_SYMBOL="󱐋 "

# Determine battery percentage
if [[ "$STATUS" == "Not charging" ]]; then
    readonly BATTERY=100
else
    readonly BATTERY=$CAPACITY
fi

# Calculate time remaining using bash arithmetic
if [[ "$STATUS" == "Charging" ]] && [[ $RATE -gt 0 ]]; then
    SECONDS_REMAINING=$(( (ENERGY_FULL - ENERGY) * 3600 / RATE ))
    HOURS=$((SECONDS_REMAINING / 3600))
    MINUTES=$(( (SECONDS_REMAINING % 3600) / 60 ))
    TIME_UNTIL=$(printf "%02d:%02d:00" $HOURS $MINUTES)
elif [[ "$STATUS" == "Discharging" ]] && [[ $RATE -gt 0 ]]; then
    SECONDS_REMAINING=$(( ENERGY * 3600 / RATE ))
    HOURS=$((SECONDS_REMAINING / 3600))
    MINUTES=$(( (SECONDS_REMAINING % 3600) / 60 ))
    TIME_UNTIL=$(printf "%02d:%02d:00" $HOURS $MINUTES)
else
    TIME_UNTIL="N/A"
fi

get_color() {
    local battery=$1
    
    # Define color stops
    local r1 g1 b1 r2 g2 b2 factor
    
    if (( battery < 50 )); then
        # Red to Yellow
        r1=255 g1=0 b1=0
        r2=255 g2=255 b2=0
        factor=$(( battery * 2 ))
    else
        # Yellow to White
        r1=255 g1=255 b1=0
        r2=255 g2=255 b2=255
        factor=$(( (battery - 50) * 2 ))
    fi
    
    # Interpolate between the two colors
    local r=$(( (r1 * (100 - factor) + r2 * factor) / 100 ))
    local g=$(( (g1 * (100 - factor) + g2 * factor) / 100 ))
    local b=$(( (b1 * (100 - factor) + b2 * factor) / 100 ))
    
    # Clamp values to 0-255 range
    (( r > 255 )) && r=255
    (( g > 255 )) && g=255
    (( b > 255 )) && b=255
    (( r < 0 )) && r=0
    (( g < 0 )) && g=0
    (( b < 0 )) && b=0
    
    printf "#%02X%02X%02X" $r $g $b
}

# Check if charging (read AC adapter status from sysfs)
if [[ -f "/sys/class/power_supply/AC/online" ]]; then
    read -r AC_ONLINE < "/sys/class/power_supply/AC/online"
elif [[ -f "/sys/class/power_supply/ACAD/online" ]]; then
    read -r AC_ONLINE < "/sys/class/power_supply/ACAD/online"
else
    # Fallback to acpi if sysfs doesn't have AC info
    if acpi -a 2>/dev/null | grep -q "on-line"; then
        AC_ONLINE=1
    else
        AC_ONLINE=0
    fi
fi

INFO=""
if hash xfce4-power-manager-settings &> /dev/null; then
    INFO="<txtclick>/home/user/Documents/Scripts/Genmon/backlight_slider.py</txtclick>"
fi

INFO+="<txt>"
if [[ $AC_ONLINE -eq 1 ]]; then
    WEIGHT="Bold"
else
    WEIGHT="Regular"
fi

COLOR=$(get_color $BATTERY)
INFO+="<span weight='${WEIGHT}' fgcolor='${COLOR}'>"
INFO+=" ${BATTERY}% "
if [[ $AC_ONLINE -eq 1 ]]; then
    INFO+="${CHARGING_SYMBOL}"
fi
INFO+="</span>"
INFO+="</txt>"

# Tooltip
MORE_INFO="<tool>"
MORE_INFO+="┌ ${MANUFACTURER} ${MODEL}\n"
MORE_INFO+="├─ Serial number: ${SERIAL_NUMBER}\n"
MORE_INFO+="├─ Technology: ${TECHNOLOGY}\n"
if [[ -n "$TEMPERATURE" ]]; then
    MORE_INFO+="├─ Temperature: +${TEMPERATURE}℃\n"
fi

if [[ $AC_ONLINE -eq 1 ]]; then
    MORE_INFO+="├─ Status: Charging ${CHARGING_SYMBOL}\n"
else
    MORE_INFO+="├─ Status: Discharging\n"
fi

if [[ $AC_ONLINE -eq 0 ]]; then
    if [[ "${BATTERY}" -eq 100 ]]; then
        MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
    else
        MORE_INFO+="└─ Remaining Time: ${TIME_UNTIL}"
    fi
elif [[ $AC_ONLINE -eq 1 ]]; then
    if [[ "${BATTERY}" -eq 100 ]]; then
        MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
    else
        MORE_INFO+="└─ Time to fully charge: ${TIME_UNTIL}"
    fi
else
    MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
fi
MORE_INFO+="</tool>"

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_INFO}"