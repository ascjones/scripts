#!/bin/bash

# Script parameters
NETWORK=$1
ADDRESS=$2

fetch_rewards () {
  curl --silent --location --request POST 'https://'$NETWORK'.subscan.io/api/scan/account/reward_slash' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "address": "'$ADDRESS'",
      "page": '$1',
      "row": '$2'
    }'
}

fetch_price () {
  curl --silent --location --request POST 'https://'$NETWORK'.subscan.io/api/open/price' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "time": '$1'
    }'
}

fetch_conversion_rate () {
  curl --silent --location 'https://api.exchangeratesapi.io/'$1'?base=USD'
}

COUNT=$(fetch_rewards 0 1 | jq '.data.count')
ROWS_PER_PAGE=20
LAST_PAGE_NUM=`expr $COUNT / $ROWS_PER_PAGE`

echo "block_num,block_time,amount_dot,price_usd,one_usd_in_euro,price_time"
for page in $(seq 0 $LAST_PAGE_NUM); do
  for row in $(fetch_rewards ${page} "$ROWS_PER_PAGE" | jq -c '.data.list[]'); do
    _jq() {
      echo ${row} | jq -r ${1}
    }

    block_num=$(_jq '.block_num')
    block_timestamp=$(_jq '.block_timestamp')
    block_time=$(date -d @"$block_timestamp" +'%Y-%m-%d %H:%M:%S')
    amount_planck=$(_jq '.amount')
    amount_dot=$(awk -v amt="$amount_planck" 'BEGIN{printf "%.7f\n", amt/10000000000}')
    price=$(fetch_price "$block_num")
    price_usd=$(echo "$price" | jq '.data.records[0].price')
    price_timestamp=$(echo "$price" | jq '.data.records[0].time')
    price_time=$(date -d @"$price_timestamp" +'%Y-%m-%d %H:%M:%S')
    conv_rate=$(fetch_conversion_rate $(date -d @"$price_timestamp" +'%Y-%m-%d') | jq '.rates.EUR')

    echo "$block_num,\"$block_time\",$amount_dot,$price_usd,$conv_rate,\"$price_time\""
  done
done
