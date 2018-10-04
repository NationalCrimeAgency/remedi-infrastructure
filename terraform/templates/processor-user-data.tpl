#!/bin/bash

# Write configuration
cat > /opt/conf/processor.cfg <<EOL
[Server Options]
    server_port=9003
    is_tls_server=false
    num_threads=20
    work_dir=/tmp/proc_text

    pre_call_templ=java -cp /opt/bin/processor.jar uk.gov.nca.remedi.PreProcessor -t -d=<WORK_DIR> -j=<JOB_UID> -l=<LANGUAGE>
    post_call_templ=java -cp /opt/bin/processor.jar:/opt/bin/stanford-truecaser.jar uk.gov.nca.remedi.PostProcessor -d=<WORK_DIR> -j=<JOB_UID> -l=<LANGUAGE> -c=${truecaser}
EOL

# Create systemd
cat > /etc/systemd/system/remedi-processor.service <<EOL
[Unit]
Description=REMEDI Processor

[Service]
User=ubuntu
ExecStart=/opt/bin/bpbd-processor -c /opt/conf/processor.cfg
WorkingDirectory=/home/ubuntu
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOL

# Install and start service

sudo systemctl daemon-reload
sudo systemctl enable remedi-processor
sudo systemctl start remedi-processor
