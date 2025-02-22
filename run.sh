#!/bin/zsh

echo "Setting up and starting the docker file"

docker-compose up -d --force-recreate

echo "Registering connector"

timeout=150
start_time=$(date +%s)

while true; do
  # Check if the endpoint is reachable
  curl -I http://localhost:8083>/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Endpoint is available. Proceeding with the POST request..."
    # Run the POST request with the schema file
    curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @mongodb.json
    break
  fi

  # Check if we've exceeded the timeout
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))
  if [ $elapsed_time -ge $timeout ]; then
    echo "Timeout reached. The endpoint is not available."
    break
  fi

  # Wait for 5 seconds before checking again
  sleep 5
done


