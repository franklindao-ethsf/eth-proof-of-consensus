source ../../../.env
mkdir -p envs
CURRENT_UNIX_TIME=`date +%s`

GOERLI_NONCE=$(cast nonce --rpc-url $GOERLI_RPC_URL $GOERLI_PUBLIC_KEY)
GNOSIS_NONCE=$(cast nonce --rpc-url $GNOSIS_RPC_URL $GNOSIS_PUBLIC_KEY)
OPTIMISM_NONCE=$(cast nonce --rpc-url $OPTIMISM_RPC_URL $OPTIMISM_PUBLIC_KEY)

GOERLI_NONCE_PLUS_ONE=$(($GOERLI_NONCE+1))
GNOSIS_NONCE_PLUS_ONE=$(($GNOSIS_NONCE+1))
OPTIMISM_NONCE_PLUS_ONE=$(($OPTIMISM_NONCE+1))

GOERLI_NONCE_PLUS_TWO=$(($GOERLI_NONCE+2))
GNOSIS_NONCE_PLUS_TWO=$(($GNOSIS_NONCE+2))
OPTIMISM_NONCE_PLUS_TWO=$(($OPTIMISM_NONCE+2))

GOERLI_NONCE_PLUS_THREE=$(($GOERLI_NONCE+3))
GNOSIS_NONCE_PLUS_THREE=$(($GNOSIS_NONCE+3))
OPTIMISM_NONCE_PLUS_THREE=$(($OPTIMISM_NONCE+3))

AMB_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE $GOERLI_PUBLIC_KEY| awk '{print $3}')
AMB_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE $GNOSIS_PUBLIC_KEY | awk '{print $3}')
AMB_OPTIMISM_ADDRESS=$(cast compute-address --nonce $OPTIMISM_NONCE $OPTIMISM_PUBLIC_KEY | awk '{print $3}')

echo "AMB_GOERLI_ADDRESS:${AMB_GOERLI_ADDRESS}"
echo "AMB_GNOSIS_ADDRESS:${AMB_GNOSIS_ADDRESS}"
echo "AMB_OPTIMISM_ADDRESS:${AMB_OPTIMISM_ADDRESS}"

DEPOSIT_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE_PLUS_ONE $GOERLI_PUBLIC_KEY | awk '{print $3}')
DEPOSIT_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE_PLUS_ONE $GNOSIS_PUBLIC_KEY | awk '{print $3}')
DEPOSIT_OPTIMISM_ADDRESS=$(cast compute-address --nonce $OPTIMISM_NONCE_PLUS_ONE $OPTIMISM_PUBLIC_KEY | awk '{print $3}')

echo "DEPOSIT_GOERLI_ADDRESS:${DEPOSIT_GOERLI_ADDRESS}"
echo "DEPOSIT_GNOSIS_ADDRESS:${DEPOSIT_GNOSIS_ADDRESS}"
echo "DEPOSIT_OPTIMISM_ADDRESS:${DEPOSIT_OPTIMISM_ADDRESS}"

WITHDRAW_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE_PLUS_TWO $GOERLI_PUBLIC_KEY | awk '{print $3}')
WITHDRAW_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE_PLUS_TWO $GNOSIS_PUBLIC_KEY | awk '{print $3}')
WITHDRAW_OPTIMISM_ADDRESS=$(cast compute-address --nonce $OPTIMISM_NONCE_PLUS_TWO $OPTIMISM_PUBLIC_KEY | awk '{print $3}')

echo "WITHDRAW_GOERLI_ADDRESS:${WITHDRAW_GOERLI_ADDRESS}"
echo "WITHDRAW_GNOSIS_ADDRESS:${WITHDRAW_GNOSIS_ADDRESS}"
echo "WITHDRAW_OPTIMISM_ADDRESS:${WITHDRAW_OPTIMISM_ADDRESS}"

USD_GOERLI_ADDRESS=$(cast compute-address --nonce $GOERLI_NONCE_PLUS_THREE $GOERLI_PUBLIC_KEY | awk '{print $3}')
USD_GNOSIS_ADDRESS=$(cast compute-address --nonce $GNOSIS_NONCE_PLUS_THREE $GNOSIS_PUBLIC_KEY | awk '{print $3}')
USD_OPTIMISM_ADDRESS=$(cast compute-address --nonce $OPTIMISM_NONCE_PLUS_THREE $OPTIMISM_PUBLIC_KEY | awk '{print $3}')

echo "USD_GOERLI_ADDRESS:${USD_GOERLI_ADDRESS}"
echo "USD_GNOSIS_ADDRESS:${USD_GNOSIS_ADDRESS}"
echo "USD_OPTIMISM_ADDRESS:${USD_OPTIMISM_ADDRESS}"

EMPTY_ADDRESS="0x80adca5ef7b6c0ef57b2f0074a6980c6054458db"
MAX_GAS_PRICE="9999999999999999999999"

echo "Deploying AMB contracts"
forge create src/amb/TrustlessAMB.sol:AMB \
   --rpc-url $GOERLI_RPC_URL \
   --private-key $GOERLI_PRIVATE_KEY \
   --constructor-args "$EMPTY_ADDRESS" "$MAX_GAS_PRICE" "$EMPTY_ADDRESS"

forge create src/amb/TrustlessAMB.sol:AMB \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "$EMPTY_ADDRESS" "$MAX_GAS_PRICE" "$EMPTY_ADDRESS"

forge create src/amb/TrustlessAMB.sol:AMB \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  --constructor-args "$EMPTY_ADDRESS" "$MAX_GAS_PRICE" "$EMPTY_ADDRESS"

echo "Deploying Deposit contracts"
forge create src/bridge/PairwiseBridge.sol:Deposit \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  --constructor-args "$AMB_GOERLI_ADDRESS" 5

forge create src/bridge/PairwiseBridge.sol:Deposit \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "$AMB_GNOSIS_ADDRESS" 100

forge create src/bridge/PairwiseBridge.sol:Deposit \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  --constructor-args "$AMB_OPTIMISM_ADDRESS" 420

echo "Deploying Withdraw contracts"
forge create src/bridge/PairwiseBridge.sol:Withdraw \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  --constructor-args "$AMB_GOERLI_ADDRESS" "$DEPOSIT_GOERLI_ADDRESS"

forge create src/bridge/PairwiseBridge.sol:Withdraw \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "$AMB_GNOSIS_ADDRESS" "$DEPOSIT_GNOSIS_ADDRESS"

forge create src/bridge/PairwiseBridge.sol:Withdraw \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  --constructor-args "$AMB_OPTIMISM_ADDRESS" "$DEPOSIT_OPTIMISM_ADDRESS"

echo "Deploying GoofyBucks contracts"
forge create src/bridge/PairwiseTokens.sol:GoofyBucks \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  --constructor-args "10000000000000" "$DEPOSIT_GOERLI_ADDRESS"

forge create src/bridge/PairwiseTokens.sol:GoofyBucks \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  --constructor-args "10000000000000" "$WITHDRAW_GNOSIS_ADDRESS"

forge create src/bridge/PairwiseTokens.sol:GoofyBucks \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  --constructor-args "10000000000000" "$WITHDRAW_OPTIMISM_ADDRESS"

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
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $WITHDRAW_OPTIMISM_ADDRESS \
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

cast send \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $DEPOSIT_OPTIMISM_ADDRESS \
  "setMapping(address,address)" "$USD_GNOSIS_ADDRESS" "$USD_GNOSIS_ADDRESS"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $WITHDRAW_GNOSIS_ADDRESS \
  "setMapping(address,address)" "$USD_OPTIMISM_ADDRESS" "$USD_OPTIMISM_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "setMapping(address,address)" "$USD_OPTIMISM_ADDRESS" "$USD_OPTIMISM_ADDRESS"

cast send \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $DEPOSIT_OPTIMISM_ADDRESS \
  "setMapping(address,address)" "$USD_OPTIMISM_ADDRESS" "$USD_OPTIMISM_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "setFA(uint16,address)" $GNOSIS_CHAIN_ID "$WITHDRAW_GNOSIS_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "setFA(uint16,address)" $OPTIMISM_CHAIN_ID "$WITHDRAW_OPTIMISM_ADDRESS"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $DEPOSIT_GNOSIS_ADDRESS \
  "setFA(uint16,address)" $GOERLI_CHAIN_ID "$WITHDRAW_GOERLI_ADDRESS"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $DEPOSIT_GNOSIS_ADDRESS \
  "setFA(uint16,address)" $OPTIMISM_CHAIN_ID "$WITHDRAW_OPTIMISM_ADDRESS"

cast send \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $DEPOSIT_OPTIMISM_ADDRESS \
  "setFA(uint16,address)" $GOERLI_CHAIN_ID "$WITHDRAW_GOERLI_ADDRESS"

cast send \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $DEPOSIT_OPTIMISM_ADDRESS \
  "setFA(uint16,address)" $GNOSIS_CHAIN_ID "$WITHDRAW_GNOSIS_ADDRESS"

cast send \
  --rpc-url $GOERLI_RPC_URL \
  --private-key $GOERLI_PRIVATE_KEY \
  $DEPOSIT_GOERLI_ADDRESS \
  "addToken(uint8,uint16,uint16[],address[])" 1 $GOERLI_CHAIN_ID "[$GOERLI_CHAIN_ID,$GNOSIS_CHAIN_ID,$OPTIMISM_CHAIN_ID]" "[$USD_GOERLI_ADDRESS,$USD_GNOSIS_ADDRESS,$USD_OPTIMISM_ADDRESS]"

cast send \
  --rpc-url $GNOSIS_RPC_URL \
  --private-key $GNOSIS_PRIVATE_KEY \
  $DEPOSIT_GNOSIS_ADDRESS \
  "addToken(uint8,uint16,uint16[],address[])" 1 $GOERLI_CHAIN_ID "[$GOERLI_CHAIN_ID,$GNOSIS_CHAIN_ID,$OPTIMISM_CHAIN_ID]" "[$USD_GOERLI_ADDRESS,$USD_GNOSIS_ADDRESS,$USD_OPTIMISM_ADDRESS]"

cast send \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $OPTIMISM_PRIVATE_KEY \
  $DEPOSIT_OPTIMISM_ADDRESS \
  "addToken(uint8,uint16,uint16[],address[])" 1 $GOERLI_CHAIN_ID "[$GOERLI_CHAIN_ID,$GNOSIS_CHAIN_ID,$OPTIMISM_CHAIN_ID]" "[$USD_GOERLI_ADDRESS,$USD_GNOSIS_ADDRESS,$USD_OPTIMISM_ADDRESS]"
