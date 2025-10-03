#!/bin/bash

CITY="Jersey+City"
API_KEY="433a4d1ac86863ecd165a890ece92fbc"
# API URL to fetch weather data
API_URL="http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=imperial"
sleep 2

# Function to get weather icon
get_weather_icon() {
    case $1 in
        Clear) echo "☀️";;
        Clouds) echo "☁️";;
        Rain) echo "🌧️";;
        Snow) echo "❄️";;
        Drizzle) echo "🌦️";;
        Thunderstorm) echo "⛈️";;
        Mist|Fog|Haze) echo "🌫️";;
        *) echo "❓";;
    esac
}

# Function to fetch weather data and extract information
get_weather() {
    local response=$(curl -s $API_URL)
    local temperature=$(echo $response | jq -r '.main.temp' | awk '{print int($1+0.5)}')
    local condition=$(echo $response | jq -r '.weather[0].main')
    local icon=$(get_weather_icon "$condition")
    local description=$(echo $response | jq -r '.weather[0].description')
    local feels_like=$(echo $response | jq -r '.main.feels_like' | awk '{print int($1+0.5)}')
    local humidity=$(echo $response | jq -r '.main.humidity')
    local wind_speed=$(echo $response | jq -r '.wind.speed')
    local wind_direction=$(echo $response | jq -r '.wind.deg')
    local pressure=$(echo $response | jq -r '.main.pressure')
    local visibility=$(echo $response | jq -r '.visibility')
    local sunrise=$(echo $response | jq -r '.sys.sunrise' | xargs -I{} date -d @{} "+%H:%M")
    local sunset=$(echo $response | jq -r '.sys.sunset' | xargs -I{} date -d @{} "+%H:%M")
    local cloudiness=$(echo $response | jq -r '.clouds.all')
    local temp_min=$(echo $response | jq -r '.main.temp_min' | awk '{print int($1+0.5)}')
    local temp_max=$(echo $response | jq -r '.main.temp_max' | awk '{print int($1+0.5)}')

    # Updated date format
    local current_date=$(date "+%a, %B %d, %Y")
    local current_time=$(date "+%-k:%M %Z")

    # Prepare the main display (temperature only)
    echo "<txt> ${temperature}°F </txt>"

    # Prepare the hover information with correct formatting
    echo "<tool>Weather in ${CITY/+/ } 

Temperature: ${temperature}°F
Feels like: ${feels_like}°F
Min/Max: ${temp_min}°F / ${temp_max}°F
Condition: ${condition} ${icon}

Humidity: ${humidity}%
Wind: ${wind_speed} mph
Wind Direction: ${wind_direction}°
Pressure: ${pressure} hPa
Cloudiness: ${cloudiness}%

Sunrise: ${sunrise}
Sunset: ${sunset}</tool>"
}

# Call the function to get weather and display
get_weather

# Create the txtclick command to open a Google search for "weather"
SEARCH_URL="https://www.google.com/search?q=weather+New+York"
echo "<txtclick>xdg-open '${SEARCH_URL}'</txtclick>"