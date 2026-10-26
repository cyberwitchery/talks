#!/bin/sh
# resets the demo: an empty lab on the lab host, and a fresh netbox that
# already describes the network (lab.yaml, mapped into netbox's model).
#
#   LAB_HOST     ssh host that runs containerlab (default: spark)
#   LAB_KEY      ssh identity for it, when the ssh config does not set one
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"
LAB_HOST="${LAB_HOST:-spark}"
topology=labs/denog/topology.clab.yml
lab() { ssh -T -o BatchMode=yes ${LAB_KEY:+-i "$LAB_KEY" -o IdentitiesOnly=yes} "$LAB_HOST" "$@"; }
alembic=bin/alembic

[ -x "$alembic" ] || { echo "no $alembic; see README.md" >&2; exit 1; }
lab test -x bin/denog/alembic-adapter-containerlab \
  || { echo "no containerlab adapter in bin/denog on $LAB_HOST" >&2; exit 1; }

echo "emptying the lab"
lab "sudo containerlab destroy -t $topology --cleanup >/dev/null 2>&1; sudo rm -f $topology; mkdir -p labs/denog"

echo "starting netbox (the first start runs migrations, a few minutes)"
rm -rf .alembic .state
mkdir -p .state
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
docker compose up -d --wait --wait-timeout 600 >/dev/null 2>&1
docker compose exec -T netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py shell -c '
from django.contrib.auth import get_user_model
from users.models import Token
t = Token.objects.create(user=get_user_model().objects.get(username="admin"))
print("nbt_{}.{}".format(t.key, t.token))' 2>/dev/null | tail -n 1 > .state/netbox-token
export NETBOX_TOKEN="$(cat .state/netbox-token)"

echo "describing the network in netbox"
"$alembic" map -f lab.yaml --spec maps/lab-to-netbox.yaml -o .state/seed.json >/dev/null
"$alembic" plan -f .state/seed.json --backend-config backends/netbox.yaml -o .state/seed-plan.json >/dev/null 2>&1
"$alembic" apply -p .state/seed-plan.json --backend-config backends/netbox.yaml >/dev/null 2>&1
rm -rf .alembic

echo "ready: netbox on http://localhost:8018 (admin / admin), the lab is empty"
echo "  export NETBOX_TOKEN=\$(cat .state/netbox-token)"
