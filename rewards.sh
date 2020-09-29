#!/bin/bash

ADDRESS=$1

fetch_rewards () {
  curl --silent --location --request POST 'https://polkadot.subscan.io/api/scan/account/reward_slash' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "address": "'$ADDRESS'",
      "page": '$1',
      "row": 10
    }'
}

fetch_price () {
  curl --silent --location --request POST 'https://polkadot.subscan.io/api/open/price' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "time": '$1'
    }'
}

# csv header
echo "block_num,block_time,amount_dot,price_usd,price_time"

PAGE=0

while true; do
  REWARDS=$(fetch_rewards "$PAGE")
  if (($(echo "$REWARDS" | jq '.data.list | length') == 0)); then
    break
  fi
  for row in $(echo $REWARDS | jq -c '.data.list[]'); do
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

    echo "$block_num,\"$block_time\",$amount_dot,$price_usd,\"$price_time\""
  done
  PAGE=$((PAGE + 1))
done



