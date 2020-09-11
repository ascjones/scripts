#!/bin/bash

ADDRESS=$1

fetch_rewards () {
  curl --silent --location --request POST 'https://polkadot.subscan.io/api/scan/account/reward_slash' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "address": "'$ADDRESS'",
      "page": 0,
      "row": '$1'
    }'
}

fetch_price () {
  curl --silent --location --request POST 'https://polkadot.subscan.io/api/open/price' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "time": '$1'
    }'
}

# fetch the count so we don't need to do paging
COUNT=$(fetch_rewards 1 | jq '.data.count')

echo "block_num,block_time,amount_dot,price_usd,price_time"
for row in $(fetch_rewards "$COUNT" | jq -c '.data.list[]'); do
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



