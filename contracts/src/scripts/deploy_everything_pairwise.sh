source ../../../.env
mkdir -p envs
CURRENT_UNIX_TIME=`date +%s`

GNOSIS_LIGHTCLIENT_ADDRESS="0xa3ae36abaD813241b75b3Bb0e9E7a37aeFD70807"
GOERLI_USD_ADDRESS="0x45cd94330ac3aea42cc21cf9315b745e27e768bd"
GNOSIS_USD_ADDRESS="0xcad264205799AF9282F27487c1A30E3A7160B1c6"

GOERLI_NONCE=$(cast nonce --rpc-url $GOERLI_RPC_URL $GOERLI_PUBLIC_KEY)
GNOSIS_NONCE=$(cast nonce --rpc-url $GNOSIS_RPC_URL $GNOSIS_PUBLIC_KEY)
GOERLI_NONCE_PLUS_ONE=$(($GOERLI_NONCE+1))
GNOSIS_NONCE_PLUS_ONE=$(($GNOSIS_NONCE+1))
GOERLI_NONCE_PLUS_TWO=$(($GOERLI_NONCE+2))
GNOSIS_NONCE_PLUS_TWO=$(($GNOSIS_NONCE+2))

AMB_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE $GOERLI_PUBLIC_KEY| awk '{print $3}')
AMB_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE $GNOSIS_PUBLIC_KEY | awk '{print $3}')

DEPOSIT_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE_PLUS_ONE $GOERLI_PUBLIC_KEY | awk '{print $3}')
WITHDRAW_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE_PLUS_ONE $GNOSIS_PUBLIC_KEY | awk '{print $3}')

USD_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE_PLUS_TWO $GOERLI_PUBLIC_KEY | awk '{print $3}')
USD_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE_PLUS_TWO $GNOSIS_PUBLIC_KEY | awk '{print $3}')

echo "AMB_GOERLI_ADDRESS: ${AMB_GOERLI_ADDRESS}"
echo "AMB_GNOSIS_ADDRESS: ${AMB_GNOSIS_ADDRESS}"
echo "DEPOSIT_GOERLI_ADDRESS: ${DEPOSIT_GOERLI_ADDRESS}"
echo "WITHDRAW_GNOSIS_ADDRESS: ${WITHDRAW_GNOSIS_ADDRESS}"
echo "USD_GOERLI_ADDRESS: ${USD_GOERLI_ADDRESS}"
echo "USD_GNOSIS_ADDRESS: ${USD_GNOSIS_ADDRESS}"

# echos variables to envs/{current_time}.env
echo "LIGHT_CLIENT_ADDRESS=${GNOSIS_LIGHTCLIENT_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "NEXT_PUBLIC_LIGHT_CLIENT_ADDRESS=${GNOSIS_LIGHTCLIENT_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "AMB_GOERLI_ADDRESS=${AMB_GOERLI_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "AMB_GNOSIS_ADDRESS=${AMB_GNOSIS_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "DEPOSIT_ADDRESS=${DEPOSIT_GOERLI_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "WITHDRAW_ADDRESS=${WITHDRAW_GNOSIS_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "NEXT_PUBLIC_DEPOSIT_ADDRESS=${DEPOSIT_GOERLI_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
echo "NEXT_PUBLIC_WITHDRAW_ADDRESS=${WITHDRAW_GNOSIS_ADDRESS}" >> envs/${CURRENT_UNIX_TIME}.env
# Copies this to a top-level .env file
cp envs/${CURRENT_UNIX_TIME}.env ../../../.address.env

EMPTY_ADDRESS="0x80adca5ef7b6c0ef57b2f0074a6980c6054458db"
MAX_GAS_PRICE="9999999999999999999999"

# Deploy AMB on Goerli
forge create src/amb/TrustlessAMB.sol:AMB \
   --rpc-url $GOERLI_RPC_URL \
   --private-key $GOERLI_PRIVATE_KEY \
   --constructor-args "$EMPTY_ADDRESS" "$MAX_GAS_PRICE" "$AMB_GNOSIS_ADDRESS" \

echo "GNOSIS_RPC_URL: ${GNOSIS_RPC_URL}"
echo "GNOSIS_PRIVATE_KEY: ${GNOSIS_PRIVATE_KEY}"
echo "GNOSIS_LIGHTCLIENT_ADDRESS: ${GNOSIS_LIGHTCLIENT_ADDRESS}"
echo "MAX_GAS_PRICE: ${MAX_GAS_PRICE}"
echo "AMB_GOERLI_ADDRESS: ${AMB_GOERLI_ADDRESS}"

# Deploy AMB on Gnosis
forge create src/amb/TrustlessAMB.sol:AMB \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "$GNOSIS_LIGHTCLIENT_ADDRESS" "$MAX_GAS_PRICE" "$AMB_GOERLI_ADDRESS" \

# # Deploy Deposit Bridge on Goerli
 forge create src/bridge/PairwiseBridge.sol:Deposit \
   --rpc-url $GOERLI_RPC_URL \
   --private-key $GOERLI_PRIVATE_KEY \
   --constructor-args "$AMB_GOERLI_ADDRESS" "$WITHDRAW_GNOSIS_ADDRESS" "$GNOSIS_CHAIN_ID" \

# Deploy Withdraw Bridge on Gnosis
forge create src/bridge/PairwiseBridge.sol:Withdraw \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "$AMB_GNOSIS_ADDRESS" "$DEPOSIT_GOERLI_ADDRESS" "$DEPOSIT_GOERLI_ADDRESS" \

# Deploy USD
forge create src/bridge/PairwiseTokens.sol:GoofyBucks \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  --constructor-args "10000000000000" "$DEPOSIT_GOERLI_ADDRESS"

forge create src/bridge/PairwiseTokens.sol:GoofyBucks \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "10000000000000" "$WITHDRAW_GNOSIS_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "setMapping(address,address)" "$USD_GOERLI_ADDRESS" "$USD_GOERLI_ADDRESS"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $WITHDRAW_GNOSIS_ADDRESS \
  "setMapping(address,address)" "$USD_GOERLI_ADDRESS" "$USD_GOERLI_ADDRESS"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $WITHDRAW_GNOSIS_ADDRESS \
  "setMapping(address,address)" "$USD_GNOSIS_ADDRESS" "$USD_GNOSIS_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "setMapping(address,address)" "$USD_GNOSIS_ADDRESS" "$USD_GNOSIS_ADDRESS"
