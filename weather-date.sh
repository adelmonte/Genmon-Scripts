#!/bin/bash

CITY="Spokane"
API_KEY="433a4d1ac86863ecd165a890ece92fbc"

 API URL to fetch weather data
API_URL="http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=imperial"

sleep 2

 #Function to fetch weather data and extract temperature and condition
get_weather() {
    local response=$(curl -s $API_URL)
    local temperature=$(echo $response | jq -r '.main.temp' | awk '{print int($1+0.5)}')
    local condition=$(echo $response | jq -r '.weather[0].main')
    echo "${temperature}°F ${condition}"
}

# Call the function to get weather and display
weather=$(get_weather)
echo " ${weather} | "