sleep 6

# Create client with user: montana 
echo "" && echo "### create client ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client node-state --chain-id chain-1 -o json >chain-1-state.json
gaiacli --home chain-2/n0/gaiacli q ibc client node-state --chain-id chain-2 -o json >chain-2-state.json
echo "12345678" | gaiacli --home chain-1/n0/gaiacli --chain-id chain-1 tx ibc client create clientchaintwo chain-2-state.json --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-2/n0/gaiacli --chain-id chain-2 tx ibc client create clientchainone chain-1-state.json --from n0 -y -o json --broadcast-mode=block

# Query client state, edge-to-edge chain 
echo "" && echo "query client state ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client state clientchaintwo
gaiacli --home chain-2/n0/gaiacli q ibc client state clientchainone

sleep 4

# Connection open-init
echo "" && echo "### connection open-init ..." && echo ""
gaiacli --home chain-2/n0/gaiacli q ibc client path >chain-2-prefix.json
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc connection open-init \
    connectionone clientchaintwo \
    connectiontwo clientchainone \
    chain-2-prefix.json \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Connection open-try
echo "" && echo "### connection open-try ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client path >chain-1-prefix.json
gaiacli --home chain-1/n0/gaiacli q ibc client header >chain-1-header.json
gaiacli --home chain-1/n0/gaiacli q ibc connection end connectionone --prove --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-1-header.json) - 1)) >connection_init_proof.json
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc client update clientchainone chain-1-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc connection open-try \
    connectiontwo clientchainone \
    connectionone clientchaintwo \
    chain-1-prefix.json \
    1.0.0 \
    connection_init_proof.json \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Connection open-ack
echo "" && echo "### connection open-ack ..." && echo ""
gaiacli --home chain-2/n0/gaiacli q ibc client header >chain-2-header.json
gaiacli --home chain-2/n0/gaiacli q ibc connection end connectiontwo --prove --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-2-header.json) - 1)) >connection_open_try_proof.json
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc client update clientchaintwo chain-2-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc connection open-ack \
    connectionone connection_open_try_proof.json \
    1.0.0 \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Connection open-confirm
echo "" && echo "### connection open-confirm ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client header >chain-1-header.json
gaiacli --home chain-1/n0/gaiacli q ibc connection end connectionone --prove --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-1-header.json) - 1)) >connection_open_ack_proof.json
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc client update clientchainone chain-1-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc connection open-confirm \
    connectiontwo connection_open_ack_proof.json \
    --from n0 -y -o json \
    --broadcast-mode=block

# Query connection
echo "" && echo "### query connection ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc connection end connectionone
gaiacli --home chain-2/n0/gaiacli q ibc connection end connectiontwo

sleep 4

# Channel open-init
echo "" && echo "### channel open-init ..." && echo ""
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc channel open-init \
    portchainone channelchainone \
    portchaintwo channelchaintwo \
    connectionone --ordered=false \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Channel open-try
echo "" && echo "### channel open-try ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client header >chain-1-header.json
gaiacli --home chain-1/n0/gaiacli q ibc channel end portchainone channelchainone --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-1-header.json) - 1)) >channel_init_proof.json
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc client update clientchainone chain-1-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc channel open-try \
    portchaintwo channelchaintwo \
    portchainone channelchainone \
    connectiontwo channel_init_proof.json \
    --ordered=false \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Channel open-ack
echo "" && echo "### channel open-ack ..." && echo ""
gaiacli --home chain-2/n0/gaiacli q ibc client header >chain-2-header.json
gaiacli --home chain-2/n0/gaiacli q ibc channel end portchaintwo channelchaintwo --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-2-header.json) - 1)) >channel_open_try_proof.json
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc client update clientchaintwo chain-2-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-1/n0/gaiacli tx ibc channel open-ack \
    portchainone channelchainone \
    channel_open_try_proof.json \
    --from n0 -y -o json \
    --broadcast-mode=block

sleep 4

# Channel open-confirm
echo "" && echo "### channel open-confirm ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc client header >chain-1-header.json
gaiacli --home chain-1/n0/gaiacli q ibc channel end portchainone channelchainone --height \
    $(($(jq -r '.value.SignedHeader.header.height' chain-1-header.json) - 1)) >channel_open_ack_proof.json
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc client update clientchainone chain-1-header.json \
    --from n0 -y -o json --broadcast-mode=block
echo "12345678" | gaiacli --home chain-2/n0/gaiacli tx ibc channel open-confirm \
    portchaintwo channelchaintwo \
    channel_open_ack_proof.json \
    --from n0 -y -o json \
    --broadcast-mode=block

# Query channel
echo "" && echo "### query channel ..." && echo ""
gaiacli --home chain-1/n0/gaiacli q ibc channel end portchainone channelchainone
gaiacli --home chain-2/n0/gaiacli q ibc channel end portchaintwo channelchaintwo

}

}
