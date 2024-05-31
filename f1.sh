#curl -s https://ergast.com/api/f1/current/next.json | jq -r '.MRData.RaceTable.Races[0].Circuit.circuitName + " - " + .MRData.RaceTable.Races[0].date'


curl -s https://ergast.com/api/f1/current/next.json | jq -r '.MRData.RaceTable.Races[0] | .Circuit.circuitName + " - " + .date + "T" + .time' | while IFS= read -r line; do
  circuit=$(echo "$line" | awk -F ' - ' '{print $1}')
  datetime=$(echo "$line" | awk -F ' - ' '{print $2}')
  localtime=$(date -d "$datetime" +"%Y-%m-%d %H:%M:%S %Z")
  echo "$circuit - $localtime"
done
