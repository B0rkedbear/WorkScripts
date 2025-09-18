#! /bin/bash
:'
    3CX Install Script v1.0
    Automatically installs 3CX v20 on Debian 12.

    NOTE: This script is intended to be ran as root. I may or may not rewrite it to work with sudo at a later date.
    
    Author: Chris Higham
    Date: 18/09/2025
'
cp /usr/share/doc/apt/examples/sources.list /etc/apt/sources.list
apt-get update && apt-get upgrade -y
#apt-get install sudo wget gnupg2 dphys-swapfile -y
apt-get install gnupg2 dphys-swapfile expect -y
wget -O- https://repo.3cx.com/key.pub | gpg --dearmor | tee /usr/share/keyrings/3cx-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee /etc/apt/sources.list.d/3cxpbx.list
apt-get update

cat <<EOF > /tmp/3cxExpect.sh
#!/usr/bin/expect
set timeout -1
spawn sh -c {apt-get install 3cxpbx -y}
expect {
  "3CX License Agreement" {
    send -- "\t\r"
    exp_continue
  }
  "Enter option: " {
    send -- "1"
    exp_continue
  }
}
EOF

chmod +x /tmp/3cxExpect.sh
/tmp/3cxExpect.sh