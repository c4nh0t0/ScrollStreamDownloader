# ScrollStreamDownloader

A simple PoC shell script to download large datasets from Elasticsearch indices using "parallel processing". This script utilizes the Scroll API to fetch data in batches and manages multiple download streams simultaneously to maximize data retrieval efficiency. I know that have better ways and tools to do this job, but the need to have a fast script that could dump Elasticsearch indexes exposed on the internet.

# Prerequisites

Before running ScrollStreamDownloader, ensure you have the following installed on your system:

`curl`: Used for making HTTP requests to the Elasticsearch server.

`jq`: Utilized for parsing JSON data and extracting necessary information.

# Installation

1. Clone the repository or download the script directly to your local machine:

`git clone https://github.com/c4nh0t0/ScrollStreamDownloader.git`

2. Make the script executable:

`sudo chmod +x ScrollStreamDownloader.sh`

# Configuration

Edit the ScrollStreamDownloader.sh script to set up the necessary parameters:

`ES_URL`: URL and Port of the exposed Elasticsearch server.

`INDEX_NAME`: Name of the Elasticsearch index from which to download data.

`OUTPUT_DIR`: Directory where downloaded JSON files will be stored.

`SCROLL_DURATION`: Duration for which the scroll context remains valid (e.g., 5m for five minutes).

`BATCH_SIZE`: Number of records to fetch per batch.

`MAX_PARALLEL_REQUESTS`: Maximum number of parallel download requests.
