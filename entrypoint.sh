#!/bin/sh

# Run confd to render config file(s)
CONFD_BACKEND="${CONFD_BACKEND:-env}"

echo "Run confd with backend ${CONFD_BACKEND}"
confd -onetime -backend $CONFD_BACKEND || exit 1

/opt/sbin/e2guardian -N -c /opt/etc/e2guardian/e2guardian.conf
