#!/bin/bash
:'
    3CX Install Script v1.1
    Automatically installs 3CX v20 on Debian 12.

    Author: Chris Higham

    To run this script directly from github use the relvant command below;

    # wget -O - https://raw.githubusercontent.com/B0rkedbear/WorkScripts/refs/heads/main/BASH/3CXAutoInstall.sh | bash

    $ wget -O - https://raw.githubusercontent.com/B0rkedbear/WorkScripts/refs/heads/main/BASH/3CXAutoInstall.sh | sudo bash

    This script was written to be ran and save me time when migrating or creating new 3CX instances on Cloud Computing Services such as AWS and Azure.
    Script will error out if ran locally as a standard user. May update this in future to integrate tests to make sure it is being ran with Root permissions
    and prompts for sudo.

    Updates;
    v1.0 -  20/09/2025 - Initial working version, tested on local VM. (18/09/2025)
    v1.1 -  20/09/2025 - Updated script to handle "Configuring openssh-server" when updating on systems that have a modified version of "/etc/ssh/sshd_config". 
            Added link to "PBX Web configuration tool" with PublicIP at end for installs on cloud services such as Azure and AWS.
'
SCRIPTPATH=/tmp/3CX
apt-get update && apt-get install expect -y
mkdir -p $SCRIPTPATH
cat <<EOF > $SCRIPTPATH/3cxInstall.sh
#!/bin/bash
apt-get update && apt-get upgrade -y
apt-get update && apt-get install sudo curl gnupg2 dphys-swapfile -y
wget -O- https://repo.3cx.com/key.pub | gpg --dearmor | tee /usr/share/keyrings/3cx-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee /etc/apt/sources.list.d/3cx.list
apt-get update && apt-get install 3cxpbx -y
EOF
cat <<EOF > $SCRIPTPATH/3cxExpect.sh
#!/usr/bin/expect
set timeout -1
spawn $SCRIPTPATH/3cxInstall.sh
expect {
  "Configuring openssh-server" {
    send -- "\r"
    exp_continue
  }
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
chmod +x $SCRIPTPATH/3cxExpect.sh $SCRIPTPATH/3cxInstall.sh
$SCRIPTPATH/3cxExpect.sh
PUBIP=$(curl -s https://ifconfig.me/ip)
echo "3CX PBX Web configuration tool can be accessed publically on the URL below;"
echo "http://$PUBIP:5015?v=2"