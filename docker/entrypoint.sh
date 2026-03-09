#!/usr/bin/env bash
# Create override_gossip_config.json when ROOT_PEER_IPS is set (required for Mainnet).
# Then run hl-visor with the given arguments.

set -e
OVERRIDE_GOSSIP="${HOME}/override_gossip_config.json"
CHAIN="${CHAIN:-Mainnet}"

if [[ -n "${ROOT_PEER_IPS:-}" ]]; then
  # Build root_node_ips JSON array from comma-separated IPs
  IPS=$(echo "$ROOT_PEER_IPS" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/.*/{"Ip": "&"}/' | paste -sd ',' -)
  echo "{ \"root_node_ips\": [$IPS], \"try_new_peers\": true, \"chain\": \"$CHAIN\", \"reserved_peer_ips\": [] }" > "$OVERRIDE_GOSSIP"
  echo "Created $OVERRIDE_GOSSIP with root_node_ips from ROOT_PEER_IPS"
fi

exec /home/hluser/hl-visor "$@"
