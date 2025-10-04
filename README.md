# Genmon-Scripts

A collection of custom scripts for the XFCE Generic Monitor (Genmon) panel plugin, providing real-time system information and media controls.

## 📋 Scripts Overview

Battery Status and Spotify are not polling. They utilize dbus monitoring and udev for instant changes, so max out your genmon "Peroid(s)".

### 🔋 Battery Status (`battery_status.sh`)
Displays battery information with a dynamic color spectrum that changes based on charge level.

**Features:**
- Color-coded battery percentage (red → orange → yellow → white as battery increases)
- Bold text and charging icon when plugged in
- Comprehensive tooltip with:
  - Battery manufacturer and model
  - Serial number and technology type
  - Current temperature
  - Estimated time remaining or time to full charge
  - Voltage information

---

### 🎵 Spotify Panel (`spotify-panel.sh`)
Shows currently playing Spotify track with click-to-focus functionality.

**Features:**
- Displays artist and track title (truncated to 30 characters)
- Click to bring Spotify window to focus
- Detailed tooltip showing artist, album, and full title
- Spotify icon indicator

**Dependencies:** `spotify`, `procps-ng`, `wmctrl`, `dbus`

---

### 🎵 Spotify D-Bus Monitor (`spotify-dbus.sh`)
Companion script that automatically refreshes the Spotify panel when track changes are detected.

**Features:**
- Monitors D-Bus for Spotify property changes
- Automatic panel refresh with cooldown protection
- Detects playback state changes

**Dependencies:** `dbus-monitor`

**Note:** Update `GENMON_ID` on line 2 to match your Genmon plugin instance number.

---

### 🌤️ Weather (`weather.sh`)
Displays current temperature with detailed weather information.

**Features:**
- Shows current temperature in Fahrenheit
- Click to open Google weather search
- Comprehensive tooltip with:
  - Feels-like temperature and min/max
  - Weather condition with emoji icon
  - Humidity, wind speed, and direction
  - Atmospheric pressure and cloudiness
  - Sunrise and sunset times

**Dependencies:** `curl`, `jq`

**Setup:** Replace the API key on line 4 with your own [OpenWeatherMap API key](https://openweathermap.org/api) and set your city on line 3.

---

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/adelmonte/Genmon-Scripts
cd Genmon-Scripts
```

2. Make scripts executable:
```bash
chmod +x *.sh
```

3. Add Generic Monitor plugins to your XFCE panel (right-click panel → Panel → Add New Items → Generic Monitor)

4. Configure each Genmon plugin:
   - Right-click the plugin → Properties
   - Set the command to the full path of the desired script
   - Adjust update period (recommended: 5-30 seconds for battery/weather, 1-2 seconds for Spotify)

## ⚙️ Additional Setup

### Battery Auto-Refresh (Optional)
To make the battery status update immediately on charging/discharging events:

1. Copy the udev rule:
```bash
sudo cp 99-battery-genmon.rules /etc/udev/rules.d/
```

2. Edit the rule to match your Genmon plugin ID:
```bash
sudo nano /etc/udev/rules.d/99-battery-genmon.rules
```

3. Reload udev rules:
```bash
sudo udevadm control --reload-rules
```

### Spotify D-Bus Monitor
To enable automatic Spotify panel updates:

1. Update `GENMON_ID` in `spotify-dbus.sh` to match your Genmon instance
2. Add the script to your autostart applications (Settings → Session and Startup → Application Autostart)

## 🎨 Customization

- **Battery colors**: Modify the `get_color()` function in `battery_status.sh`
- **Spotify max length**: Change `MAX_CHARS` variable in `spotify-panel.sh` (line 17)
- **Weather location**: Update `CITY` variable in `weather.sh` (line 3)
- **Weather units**: Change `units=imperial` to `units=metric` in the API URL (line 6)
