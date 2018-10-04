#!/bin/sh
set -e

# Clear a space at the end of the file
sudo bash -c 'echo "" >> /etc/ssh/sshd_config'
sudo bash -c 'echo "" >> /etc/ssh/sshd_config'

# Configure KexAlgorithms
# Default KexAlgorithms:
# kexalgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
sudo bash -c 'sudo echo "# Set Key Exchange Algorithms" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "" >> /etc/ssh/sshd_config'

# Configure Ciphers
# Default Ciphers:
# ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-cbc,aes192-cbc,aes256-cbc,blowfish-cbc,cast128-cbc,3des-cbc
sudo bash -c 'sudo echo "# Set Ciphers" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "" >> /etc/ssh/sshd_config'

# Configure MACs
# Default MACs:
# macs umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1
sudo bash -c 'sudo echo "# Set MACs" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config'
sudo bash -c 'sudo echo "" >> /etc/ssh/sshd_config'
