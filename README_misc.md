This file contains optional configuration. Refer to `README.md` the essential information.

## Running as a System Service
Many node operators prefer to run the node as a system service.

Create the system service config file:
```
sudo nano /etc/systemd/system/hl-visor.service
```

Add the required information to the config, replace ALL instances of USERNAME:
```
[Unit]
Description=HL-Visor Non-Validator Service
After=network.target

[Service]
Type=simple
User=USERNAME
WorkingDirectory=/home/USERNAME
ExecStart=/home/USERNAME/hl-visor run-non-validator
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

```
Enable the service:
```
sudo systemctl enable hl-visor.service
```

Start the service:
```
sudo systemctl start hl-visor
```

And finally to follow the logs use command:
```
journalctl -u hl-visor -f
```

### Running with Docker

Docker uses **Ubuntu 24.04** inside the image, so you can run the node on a host running **Ubuntu 22** (or other distros) and still meet the “Ubuntu 24.04 only” requirement.

The default `docker-compose.yml` is set up for a **Mainnet non-validator RPC node** (EVM RPC + Info API). For Mainnet you must set `ROOT_PEER_IPS` (comma-separated seed peer IPs); a default list is provided. Get current peers with:

```bash
curl -sS -X POST -H "Content-Type: application/json" -d '{ "type": "gossipRootIps" }' https://api.hyperliquid.xyz/info
```

To build and run:

```bash
docker compose build
docker compose up -d
```

- **EVM RPC:** `http://localhost:3001/evm`
- **Info API:** `http://localhost:3001/info`
- Node data: Docker volume `hl-data` (persists under `~/hl/data` in the container).

To use **Testnet** instead, build with:

```bash
docker compose build --build-arg CHAIN=Testnet --build-arg HL_VISOR_URL=https://binaries.hyperliquid-testnet.xyz/Testnet/hl-visor --build-arg HL_VISOR_ASC_URL=https://binaries.hyperliquid-testnet.xyz/Testnet/hl-visor.asc
```

Then run with `ROOT_PEER_IPS` unset or leave it; Testnet does not require seed peers in the same way.

## Additional Configuration
The default number of gossip peers for non-validating nodes is 8. To configure a different number between 8 and 100 inclusive, put that integer as `n_gossip_peers` in `override_gossip_config.json`. This does not require restarting the node to take effect.

To override the public IP address of the node:
```
echo "1.2.3.4" > ~/hl/override_public_ip_address
```
