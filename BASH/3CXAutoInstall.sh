#! /bin/bash
:'
    3CX Install Script v1.0
    Automatically installs 3CX v20 on Debian 12.

    Author: Chris Higham
    Date: 18/09/2025

    To run this script directly from github use the relvant command below;
    # wget -O - https://raw.githubusercontent.com/B0rkedbear/WorkScripts/refs/heads/main/BASH/3CXAutoInstall.sh | bash

    $ wget -O - https://raw.githubusercontent.com/B0rkedbear/WorkScripts/refs/heads/main/BASH/3CXAutoInstall.sh | sudo bash
    This script was written to be ran and save me time when migrating or creating new 3CX instances on Cloud Computing Services such as AWS and Azure.
    Script will error out if ran locally as a standard user. May update this in future to integrate tests to make sure it is being ran with Root permissions
    and prompts for sudo.
'
apt-get update && apt-get upgrade -y
apt-get install sudo expect gnupg2 dphys-swapfile -y
wget -O- https://repo.3cx.com/key.pub | gpg --dearmor | tee /usr/share/keyrings/3cx-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee /etc/apt/sources.list.d/3cx.list
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