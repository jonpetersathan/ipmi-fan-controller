#!/bin/sh
echo "(1/4) Cleaning up previous installs..."
systemctl disable fan-control 2> /dev/null
systemctl stop fan-control 2> /dev/null
rm -rf /usr/local/lib/fan-control
rm -f /usr/lib/systemd/system/fan-control.service

set -e
echo "(2/4) Downloading and installing fan controller..."
mkdir /usr/local/lib/fan-control
curl -Ss https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/main.py -o /usr/local/lib/fan-control/main.py
curl -Ss https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/utils.py -o /usr/local/lib/fan-control/utils.py
curl -Ss https://raw.githubusercontent.com/jonpetersathan/ipmi-fan-controller/refs/heads/main/fan-control.service -o /usr/lib/systemd/system/fan-control.service

echo "(3/4) Setting permissions..."
chown -R root:root /usr/local/lib/fan-control
chmod -R 644 /usr/local/lib/fan-control
chown root:root /usr/lib/systemd/system/fan-control.service
chmod 644 /usr/lib/systemd/system/fan-control.service

echo "(4/4) Installing systemd service..."
systemctl enable fan-control
systemctl start fan-control

echo Done. Installation completed succesfully.