#!/bin/bash

# Write configuration
cat > /opt/conf/server.cfg <<EOL
[Server Options]
    server_port=9001
    is_tls_server=false
    num_threads=25
    source_lang=${language_name}
    target_lang=English

[Language Models]
    lm_conn_string=/opt/models/${language}_en.lm
    unk_word_log_e_prob=-10.7763748168945
    lm_feature_weights=0.2

[Translation Models]
    tm_conn_string=/opt/models/${language}_en.tm
    tm_feature_weights=1.0|1.0|1.0|1.0|1.0
    tm_unk_features=4.539992e-5|4.539992e-5|4.539992e-5|4.539992e-5|2.71828182846
    tm_trans_lim=30
    tm_min_trans_prob=1e-20
    tm_word_penalty=-0.3

[Reordering Models]
    rm_conn_string=/opt/models/${language}_en.rm
    rm_feature_weights=1.0|1.0|1.0|1.0|1.0|1.0

[Decoding Options]
    de_pruning_threshold=0.1
    de_stack_capacity=100
    de_max_source_phrase_length=7
    de_max_target_phrase_length=7
    de_dist_lim=5
    de_lin_dist_penalty=1.0
    de_is_gen_lattice=false
    de_lattices_folder=./lattices
    de_lattice_id2name_file_ext=feature_id2name
    de_feature_scores_file_ext=feature_scores
    de_lattice_file_ext=lattices
EOL

# Create Model Loading Script

cat > /opt/bin/loadModels.sh <<'EOL'
#!/bin/bash

DEVICE=$(lsblk | grep ${model_volume_size}G | cut -d ' ' -f 1)

mkdir -p /opt/models
mkfs -t ext4 /dev/$$DEVICE
mount /dev/$$DEVICE /opt/models
aws s3 cp s3://${models_bucket}/${language}_en.lm /opt/models
aws s3 cp s3://${models_bucket}/${language}_en.rm /opt/models
aws s3 cp s3://${models_bucket}/${language}_en.tm /opt/models
EOL

chmod +x /opt/bin/loadModels.sh

# Create systemd (Model Loading)
cat > /etc/systemd/system/model-loader.service <<EOL
[Unit]
Description=REMEDI Model Loader
Before=remedi-server.service

[Service]
Type=oneshot
ExecStart=/opt/bin/loadModels.sh

[Install]
RequiredBy=remedi-server.service
WantedBy=multi-user.target
EOL

# Create systemd (REMEDI Server)
cat > /etc/systemd/system/remedi-server.service <<EOL
[Unit]
Description=REMEDI Translation Server

[Service]
User=ubuntu
ExecStart=/opt/bin/bpbd-server -c /opt/conf/server.cfg
WorkingDirectory=/home/ubuntu
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOL

# Install and start service

sudo systemctl daemon-reload
sudo systemctl enable model-loader
sudo systemctl enable remedi-server
sudo systemctl start model-loader
sudo systemctl start remedi-server
