#!/bin/bash

# Get the current time in PT in 24-hour format
pt_time=$(date +"%H:%M")

# Get the current time in Turkey in 24-hour format
turkey_time=$(TZ="Europe/Istanbul" date +"%H:%M")

# Print the times on top of each other
echo -e " $pt_time PT\n $turkey_time TR"
