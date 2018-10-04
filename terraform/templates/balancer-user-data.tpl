#!/bin/bash

# Write configuration
cat > /opt/conf/balancer.cfg <<EOL
[Server Options]
    server_port=9002
    is_tls_server=false
    num_req_threads=10
    num_resp_threads=10
    reconnect_time_out=4000;
EOL

SERVERNAMES="    translation_server_names="
for number in {1..${server_count}}; do
SERVERNAMES="$${SERVERNAMES}SERVER_NAME_$number|"
done
SERVERNAMES=$${SERVERNAMES::-1}

echo "$SERVERNAMES" >> /opt/conf/balancer.cfg

for number in {1..${server_count}}; do
echo "[SERVER_NAME_$number]" >> /opt/conf/balancer.cfg
echo "    server_uri=ws://remedi-server-$number.${domain}:9001" >> /opt/conf/balancer.cfg
echo "    load_weight=1" >> /opt/conf/balancer.cfg
done

# Create systemd
cat > /etc/systemd/system/remedi-balancer.service <<EOL
[Unit]
Description=REMEDI Balancer

[Service]
User=ubuntu
ExecStart=/opt/bin/bpbd-balancer -c /opt/conf/balancer.cfg
WorkingDirectory=/home/ubuntu
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOL

# Install and start service

sudo systemctl daemon-reload
sudo systemctl enable remedi-balancer
sudo systemctl start remedi-balancer
