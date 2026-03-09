FROM ubuntu:24.04

ARG USERNAME=hluser
ARG USER_UID=10000
ARG USER_GID=$USER_UID

# Chain: Mainnet or Testnet. Mainnet requires ROOT_PEER_IPS at runtime.
ARG CHAIN=Mainnet
ARG PUB_KEY_URL=https://raw.githubusercontent.com/hyperliquid-dex/node/refs/heads/main/pub_key.asc

# Binary URLs depend on chain (override when building for Testnet)
ARG HL_VISOR_URL=https://binaries.hyperliquid.xyz/Mainnet/hl-visor
ARG HL_VISOR_ASC_URL=https://binaries.hyperliquid.xyz/Mainnet/hl-visor.asc

# Create user and install dependencies
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update -y && apt-get install -y curl gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/$USERNAME/hl/data /home/$USERNAME/hl/hyperliquid_data /home/$USERNAME/docker \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Configure chain (Mainnet or Testnet)
RUN echo "{\"chain\": \"$CHAIN\"}" > /home/$USERNAME/visor.json

# Import GPG public key
RUN curl -o /home/$USERNAME/pub_key.asc $PUB_KEY_URL \
    && gpg --import /home/$USERNAME/pub_key.asc

# Download and verify hl-visor binary
RUN curl -o /home/$USERNAME/hl-visor $HL_VISOR_URL \
    && curl -o /home/$USERNAME/hl-visor.asc $HL_VISOR_ASC_URL \
    && gpg --verify /home/$USERNAME/hl-visor.asc /home/$USERNAME/hl-visor \
    && chmod +x /home/$USERNAME/hl-visor

# Entrypoint: writes override_gossip_config.json when ROOT_PEER_IPS is set (required for Mainnet), then runs visor
COPY --chown=hluser:hluser docker/entrypoint.sh /home/hluser/docker/entrypoint.sh
RUN chmod +x /home/hluser/docker/entrypoint.sh

ENV CHAIN=$CHAIN

# Gossip ports + RPC (EVM + Info) port
EXPOSE 4000-4010 3001

ENTRYPOINT ["/home/hluser/docker/entrypoint.sh"]
CMD ["run-non-validator", "--replica-cmds-style", "recent-actions", "--serve-eth-rpc", "--serve-info"]
