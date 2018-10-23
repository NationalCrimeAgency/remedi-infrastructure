#!/bin/bash

# Write configuration
cat > /opt/conf/balancer.cfg <<EOL
[Server Options]
    server_port=9002
EOL

if [ -z "${cert}" ] || [ -z "${cert_key}" ]; then

#TLS Disabled
cat >> /opt/conf/balancer.cfg <<EOL
    is_tls_server=false
EOL

else

#TLS Enabled
echo "${cert}" > /opt/conf/remedi-balancer.crt
echo "${cert_key}" > /opt/conf/remedi.key

export RANDFILE=.rnd
openssl dhparam -out /opt/conf/dh2048.pem 2048

cat >> /opt/conf/balancer.cfg <<EOL
    is_tls_server=true
    tls_mode=mod
    tls_crt_file=/opt/conf/remedi-balancer.crt
    tls_key_file=/opt/conf/remedi.key
    tls_tmp_dh_file=/opt/conf/dh2048.pem
    tls_ciphers=${ciphers}
EOL

fi

cat >> /opt/conf/balancer.cfg <<EOL
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
