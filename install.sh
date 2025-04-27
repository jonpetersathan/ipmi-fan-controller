#!/bin/sh
echo Cleaning up previous installs
systemctl disable fan-control 2> /dev/null
systemctl stop fan-control 2> /dev/null
rm -rf /usr/local/lib/fan-control
rm -f /usr/lib/systemd/system/fan-control.service

set -e
echo Downloading fan control service files
mkdir /usr/local/lib/fan-control
curl https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/main.py -o /usr/local/lib/fan-control/main.py
curl https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/utils.py -o /usr/local/lib/fan-control/utils.py
curl https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/fan-control.service -o /usr/lib/systemd/system/fan-control.service

echo Setting ownerships and permissions
chown -R root:root /usr/local/lib/fan-control
chmod -R 644 /usr/local/lib/fan-control
chown root:root /usr/lib/systemd/system/fan-control.service
chmod 644 /usr/lib/systemd/system/fan-control.service

echo Enabling fan control service
systemctl enable fan-control
systemctl start fan-control

echo Done. Installation completed succesfully.