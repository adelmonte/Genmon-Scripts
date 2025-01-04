#!/usr/bin/env bash
# Dependencies: acpi, bash>=3.2, coreutils, file, gawk, grep, xfce4-power-manager

# Makes the script more portable
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# As of Linux kernel 2.6.x you need to use /sys/class/power_supply/BATX (X=integer)
readonly MANUFACTURER=$(awk '{print $1}' /sys/class/power_supply/BAT*/manufacturer)
readonly MODEL=$(awk '{print $1}' /sys/class/power_supply/BAT*/model_name)
readonly SERIAL_NUMBER=$(awk '{print $1}' /sys/class/power_supply/BAT*/serial_number)
readonly TECHNOLOGY=$(awk '{print $1}' /sys/class/power_supply/BAT*/technology)
readonly TYPE=$(awk '{print $1}' /sys/class/power_supply/BAT*/type)
readonly ENERGY_FULL=$(awk '{$1 = $1 / 1000000; print $1}' /sys/class/power_supply/BAT*/energy_full)
readonly ENERGY_DESIGN=$(awk '{$1 = $1 / 1000000; print $1}' /sys/class/power_supply/BAT*/energy_full_design)
readonly ENERGY=$(awk '{$1 = $1 / 1000000; print $1}' /sys/class/power_supply/BAT*/energy_now)
readonly VOLTAGE=$(awk '{$1 = $1 / 1000000; print $1}' /sys/class/power_supply/BAT*/voltage_now)
readonly RATE=$(awk '{$1 = $1 / 1000000; print $1}' /sys/class/power_supply/BAT*/power_now)
readonly TEMPERATURE=$(acpi -t | awk '{print $4}')
readonly TIME_UNTIL=$(acpi | awk '{print $5}')
readonly CHARGING_SYMBOL="󱐋 "
readonly BATTERY=$(
    if [[ $(cat /sys/class/power_supply/BAT*/status) == "Not charging" ]]; then
        echo "100"
    else
        awk '{print $1}' /sys/class/power_supply/BAT*/capacity
    fi
)


get_color() {
    local battery=$1
    
    # Define color stops
    local -a colors=(
        "255 0 0"      # Red (0%)
        "255 255 0"    # Yellow (50%)
        "255 255 255"  # White (100%)
    )
    
    local index
    if (( battery < 50 )); then
        index=0
    else
        index=1
    fi
    
    # Get the two colors to interpolate between
    IFS=' ' read -r r1 g1 b1 <<< "${colors[index]}"
    IFS=' ' read -r r2 g2 b2 <<< "${colors[index+1]}"
    
    # Calculate the interpolation factor
    local factor
    if (( battery < 50 )); then
        factor=$(( battery * 2 ))
    else
        factor=$(( (battery - 50) * 2 ))
    fi
    
    # Interpolate between the two colors
    local r=$(( (r1 * (100 - factor) + r2 * factor) / 100 ))
    local g=$(( (g1 * (100 - factor) + g2 * factor) / 100 ))
    local b=$(( (b1 * (100 - factor) + b2 * factor) / 100 ))
    
    # Ensure the color values are within the valid range (0-255)
    r=$(( r > 255 ? 255 : (r < 0 ? 0 : r) ))
    g=$(( g > 255 ? 255 : (g < 0 ? 0 : g) ))
    b=$(( b > 255 ? 255 : (b < 0 ? 0 : b) ))
    
    printf "#%02X%02X%02X" $r $g $b
}

if hash xfce4-power-manager-settings &> /dev/null; then
  INFO+="<txtclick>/home/user/Documents/Scripts/backlight_slider.py</txtclick>"
fi

INFO+="<txt>"
CHARGING=0
if acpi -a | grep -i "on-line" &> /dev/null; then
    CHARGING=1
    WEIGHT="Bold"
else
    WEIGHT="Regular"
fi

COLOR=$(get_color $BATTERY $CHARGING)
INFO+="<span weight='${WEIGHT}' fgcolor='${COLOR}'>"
INFO+=" ${BATTERY}% "
if [ $CHARGING -eq 1 ]; then
  INFO+="${CHARGING_SYMBOL}"
fi
INFO+="</span>"
INFO+="</txt>"

# Tooltip
MORE_INFO="<tool>"
MORE_INFO+="┌ ${MANUFACTURER} ${MODEL}\n"
MORE_INFO+="├─ Serial number: ${SERIAL_NUMBER}\n"
MORE_INFO+="├─ Technology: ${TECHNOLOGY}\n"
MORE_INFO+="├─ Temperature: +${TEMPERATURE}℃\n"
if [ $CHARGING -eq 1 ]; then
  MORE_INFO+="├─ Status: Charging ${CHARGING_SYMBOL}\n"
else
  MORE_INFO+="├─ Status: Discharging\n"
fi
if [ $CHARGING -eq 0 ]; then # if AC adapter is offline
  if [ "${BATTERY}" -eq 100 ]; then # if battery is fully charged
    MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
  else
    MORE_INFO+="└─ Remaining Time: ${TIME_UNTIL}"
  fi
elif [ $CHARGING -eq 1 ]; then # if AC adapter is online
  if [ "${BATTERY}" -eq 100 ]; then # if battery is fully charged
    MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
  else
    MORE_INFO+="└─ Time to fully charge: ${TIME_UNTIL}"
  fi
else # if battery is in unknown state (no battery at all, throttling, etc.)
  MORE_INFO+="└─ Voltage: ${VOLTAGE} V"
fi
MORE_INFO+="</tool>"

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_INFO}"