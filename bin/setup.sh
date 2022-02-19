#!/bin/sh
#BASE=/data/drivers/dbus-mqtt-devices
BASE=$(dirname $(dirname $(realpath "$0")))

echo "Install dbus-mqtt-devices to $BASE started"
cd $BASE

echo "Ensure Python's Pip is installed"
python -m ensurepip

echo "Pip install module dependencies"
python -m pip install -r requirements.txt

echo "Set up Victron module libraries"
rm -fr $BASE/ext/dbus-mqtt $BASE/ext/velib_python
ln -s /opt/victronenergy/dbus-mqtt $BASE/ext
ln -s /opt/victronenergy/dbus-digitalinputs/ext/velib_python $BASE/ext

echo "Set up device service to autorun on restart"
chmod +x $BASE/dbus_mqtt_devices.py
# Use awk to inject correct BASE path into the run script
awk -v base=$BASE '{gsub(/\$\{BASE\}/,base);}1' $BASE/bin/service/run.tmpl >$BASE/bin/service/run
chmod -R a+rwx $BASE/bin/service
rm -f /service/dbus-mqtt-devices
ln -s $BASE/bin/service /service/dbus-mqtt-devices

CMD="ln -s $BASE/bin/service /service/dbus-mqtt-devices"
if ! grep -q "$CMD" /data/rc.local; then
    echo "$CMD" >> /data/rc.local
fi

echo "Install dbus-mqtt-devices complete"