#!/usr/bin/env bash
# Setup and run a Mainnet non-validator RPC node for Hyperliquid.
# Requires: Ubuntu 24.04, 16 vCPUs, 64 GB RAM, 500 GB SSD.
# Ports 4001 and 4002 must be open for gossip.

set -e

echo "=== Hyperliquid Mainnet Non-Validator RPC Node Setup ==="

# 1. Configure chain for Mainnet
echo "Configuring chain: Mainnet"
echo '{"chain": "Mainnet"}' > ~/visor.json

# 2. Download visor binary (Mainnet)
echo "Downloading hl-visor (Mainnet)..."
curl -sSfL https://binaries.hyperliquid.xyz/Mainnet/hl-visor -o ~/hl-visor
chmod +x ~/hl-visor

# 3. Mainnet requires at least one root peer in override_gossip_config.json
# Using a few known root peers from the validator community (Japan for low latency)
ROOT_PEERS='[{"Ip": "64.31.48.111"}, {"Ip": "64.31.51.137"}, {"Ip": "34.84.25.59"}]'
echo "Creating override_gossip_config.json with seed peers..."
echo "{ \"root_node_ips\": $ROOT_PEERS, \"try_new_peers\": true, \"chain\": \"Mainnet\", \"reserved_peer_ips\": [] }" > ~/override_gossip_config.json

# 4. Optional: verify signed binary (uncomment if you have gpg and pub_key.asc)
# gpg --import "$(dirname "$0")/../pub_key.asc"
# curl -sSfL https://binaries.hyperliquid.xyz/Mainnet/hl-visor.asc -o ~/hl-visor.asc
# gpg --verify ~/hl-visor.asc ~/hl-visor

echo ""
echo "Setup complete. To start the non-validator RPC node, run:"
echo ""
echo "  ~/hl-visor run-non-validator --serve-eth-rpc --serve-info"
echo ""
echo "  - EVM RPC:    http://localhost:3001/evm"
echo "  - Info API:   http://localhost:3001/info"
echo ""
echo "To run in foreground now, press Enter; otherwise Ctrl+C to exit."
read -r

~/hl-visor run-non-validator --serve-eth-rpc --serve-info
