#!/bin/sh
# resets the demo: an empty lab, and a fresh netbox seeded from lab.yaml.
#
#   LAB_HOST     ssh host that runs containerlab (default: denog-lab)
#   LAB_KEY      ssh identity for it, when the ssh config does not set one
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"
LAB_HOST="${LAB_HOST:-denog-lab}"
lab() { ssh -T -o BatchMode=yes ${LAB_KEY:+-i "$LAB_KEY" -o IdentitiesOnly=yes} "$LAB_HOST" "$@"; }
alembic=bin/alembic

[ -x "$alembic" ] || { echo "no $alembic; see README.md" >&2; exit 1; }
lab true 2>/dev/null \
  || { echo "cannot ssh to $LAB_HOST; set LAB_KEY, or an IdentityFile in the ssh config" >&2; exit 1; }
for a in containerlab prometheus; do
  lab test -x "bin/denog/alembic-adapter-$a" \
    || { echo "no $a adapter in bin/denog on $LAB_HOST" >&2; exit 1; }
done

echo "emptying the lab"
./teardown >/dev/null

# ./monitor starts it, once the lab's network exists
echo "copying the monitoring to $LAB_HOST"
lab 'mkdir -p denog-monitoring/targets'
rsync -a --delete --exclude targets \
  -e "ssh -T -o BatchMode=yes ${LAB_KEY:+-i $LAB_KEY -o IdentitiesOnly=yes}" \
  monitoring/ "$LAB_HOST:denog-monitoring/"

echo "starting netbox (the first start runs migrations, a few minutes)"
rm -rf .alembic .state
mkdir -p .state
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
docker compose up -d --build --wait --wait-timeout 600 >/dev/null 2>&1 \
  || { echo "netbox did not start; is docker running? see docker compose logs netbox" >&2; exit 1; }
docker compose exec -T netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py shell -c '
from django.contrib.auth import get_user_model
from users.models import Token
t = Token.objects.create(user=get_user_model().objects.get(username="admin"))
print("nbt_{}.{}".format(t.key, t.token))' 2>/dev/null | tail -n 1 > .state/netbox-token
export NETBOX_TOKEN="$(cat .state/netbox-token)"

docker compose exec -T netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py \
  shell < netbox/seed.py 2>/dev/null | grep -q SEEDED \
  || { echo "adding alembic's backends failed; run netbox/seed.py by hand to see why" >&2; exit 1; }

echo "describing the network in netbox"
seed() { "$alembic" "$@" >.state/seed.log 2>&1 || { cat .state/seed.log >&2; exit 1; }; }
seed map -f lab.yaml --spec maps/lab-to-netbox.yaml -o .state/seed.json
seed plan -f .state/seed.json --backend-config backends/netbox.yaml -o .state/seed-plan.json
seed apply -p .state/seed-plan.json --backend-config backends/netbox.yaml
rm -rf .alembic

echo "ready: netbox on http://localhost:8018 (admin / admin), the lab is empty"
echo "next: ./deploy"
