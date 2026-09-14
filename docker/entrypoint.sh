#!/bin/sh
set -eu

# This is deployment policy rather than user settings.  Reapply it after every
# restart so the persistent state cannot accidentally broaden network access.
cp /opt/dsh/minimal-network.yml "$DSH_HOME/cordis.patch.yml"

# dsh intentionally binds only to its loopback interface.  This relay is the
# sole process listening on the internal Docker interface.
socat TCP-LISTEN:8080,reuseaddr,fork TCP:127.0.0.1:3080 &

exec dsh web --host 127.0.0.1 --port 3080 --no-open
