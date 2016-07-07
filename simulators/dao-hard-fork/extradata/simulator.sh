#!/bin/bash
set -e

# Start a new client node
echo -n "Starting a new client..."
id=`curl -sf -X POST $HIVE_SIMULATOR/nodes`
ip=`curl -sf $HIVE_SIMULATOR/nodes/$id`
echo "Started node $id at $ip"

# Let it mine past the DAO fork block
curl -sf -X POST --data '{"jsonrpc":"2.0","method":"miner_start","params":[1],"id":0}' $ip:8545

while [ true ]; do
	block=`curl -sf -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $ip:8545 | jq '.result' | tr -d '"'`
	block=$((16#${block#*x}))
	if [ "$block" -gt "$HIVE_FORK_DAO" ]; then
		break
	fi
	sleep 1
done
curl -sf -X POST --data '{"jsonrpc":"2.0","method":"miner_stop","params":[],"id":2}' $ip:8545

# Retrieve DAO fork block and validate it's extradata ("dao-hard-fork" -> 0x64616f2d686172642d666f726b)
extra=`curl -sf -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[$HIVE_FORK_DAO, false],\"id\":3}" $ip:8545 | jq '.result.extraData' | tr -d '"'`
if [ "$extra" != "0x64616f2d686172642d666f726b" ]; then
	echo "DAO fork block extra-data mismatch: have $extra, want 0x64616f2d686172642d666f726b"
	exit -1
fi