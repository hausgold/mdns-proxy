#!/bin/bash

# dbus-daemon tries to reads passwd/group data, and on an non-systemd system,
# where systemd is configured for NSS it causes a 90 second hang. So we drop
# the systemd configuration for NSS.
#
# See: https://github.com/systemd/systemd/issues/16471#issuecomment-662377106
sed -i 's/ systemd//g' /etc/nsswitch.conf

# Prepare the environment for dbus
rm -rf /var/run/dbus /run/dbus
mkdir -p /var/run/dbus/ /run/dbus
chmod ugo+rwx /var/run/dbus/ /run/dbus

# systemd service activation makes no sense on a non-systemd system.
# Looks like this is not needed currently/anymore.
# cat >/etc/dbus-1/system.d/no-systemd.conf <<EOF
# <!DOCTYPE busconfig PUBLIC
#  "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
#  "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
# <busconfig>
#   <limit name="service_start_timeout">1</limit>
#   <servicehelper>/bin/true</servicehelper>
# </busconfig>
# EOF

# Start dbus
exec /usr/bin/dbus-daemon --system --nofork
