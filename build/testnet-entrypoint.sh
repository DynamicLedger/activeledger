#/bin/sh

TESTNET_FOLDER="/activeledger/data"
TESTNET_FILE="testnet"

# Clean up stale files
find $TESTNET_FOLDER -name "LOCK" -delete
find $TESTNET_FOLDER -name ".PID" -delete
find $TESTNET_FOLDER -name "node_modules" -type l -delete

if [ ! -f "$TESTNET_FOLDER/$TESTNET_FILE" ]; then

  echo "No testnet found, generating..."
  cd $TESTNET_FOLDER && node /activeledger/packages/activeledger/lib/index.js --testnet

fi

echo "Starting testnet..."
cd $TESTNET_FOLDER && node $TESTNET_FILE
