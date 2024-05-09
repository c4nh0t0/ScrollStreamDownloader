#!/bin/bash

# Configuration
ES_URL="http://elasticsearch-server-address:port"
INDEX_NAME="index-name"
OUTPUT_DIR="elasticsearch_data"
SCROLL_DURATION="5m"
BATCH_SIZE=1000
MAX_PARALLEL_REQUESTS=5

# Setup
mkdir -p "$OUTPUT_DIR"
COUNT=0

# Initialize scroll
echo "Initializing scroll..."
INITIAL_SCROLL=$(curl -s -X GET "$ES_URL/$INDEX_NAME/_search?scroll=$SCROLL_DURATION" -H 'Content-Type: application/json' -d'
{
  "size": '$BATCH_SIZE',
  "query": {
    "match_all": {}
  }
}')

SCROLL_ID=$(echo $INITIAL_SCROLL | jq -r '._scroll_id')
if [ -z "$SCROLL_ID" ] || [ "$SCROLL_ID" == "null" ]; then
  echo "Failed to initialize scroll context. Exiting."
  exit 1
fi

echo $INITIAL_SCROLL | jq . > "$OUTPUT_DIR/$((++COUNT)).json"

# Function to clean up scroll
cleanup() {
  echo "Cleaning up scroll ID $SCROLL_ID..."
  curl -s -X DELETE "$ES_URL/_search/scroll" -H 'Content-Type: application/json' -d'
  {
    "scroll_id": ["'$SCROLL_ID'"]
  }'
  echo "Cleanup completed."
}

# Set trap to clean up in case of interruption
trap cleanup EXIT

# Scroll through the data
while true; do
  if [[ $(jobs -r | wc -l) -ge $MAX_PARALLEL_REQUESTS ]]; then
    wait -n
  fi

  {
    RESPONSE=$(curl -s -X GET "$ES_URL/_search/scroll" -H 'Content-Type: application/json' -d'
    {
      "scroll": "'$SCROLL_DURATION'",
      "scroll_id": "'$SCROLL_ID'"
    }')

    HITS=$(echo $RESPONSE | jq '.hits.hits | length')
    if [ "$HITS" -eq 0 ]; then
      break
    fi

    echo $RESPONSE | jq . > "$OUTPUT_DIR/$((++COUNT)).json"
  } & # Background the task
done

wait # Wait for all background tasks to complete

echo "Download completed."
