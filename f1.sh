curl -s https://ergast.com/api/f1/current/next.json | jq -r '.MRData.RaceTable.Races[0].Circuit.circuitName + " - " + .MRData.RaceTable.Races[0].date'