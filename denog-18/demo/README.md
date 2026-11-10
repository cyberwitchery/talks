# demo: deploy and drift

deploy a lab from netbox to containerlab, pull a cable by hand, find the drift
on the way back, and deploy again.

```text
netbox  → map → containerlab     deploy
netbox ← map ← containerlab      drift
```

## what runs where

- **the lab host** (`LAB_HOST`, default `denog-lab`): containerlab, with the
  adapters in `bin/denog/`. the lab `denog` has two sr linux spines, two alpine
  leaves and five links (`lab.yaml`). alembic runs the adapters over ssh
  (`bin/`).
- **the monitoring**, also on the lab host: blackbox, prometheus and grafana
  (`monitoring/`), on containerlab's management network. `setup.sh` copies it
  over, `./monitor` starts it.
- **this machine**: netbox 4.6.2 with the alembic plugin on
  http://localhost:8018, and alembic 0.13.0 at `bin/alembic`.

the containerlab and prometheus adapters are part of alembic-ops, so they are
not in this repo.

## setup

```sh
gh release download v0.13.0 -R cyberwitchery/alembic \
  -p 'alembic-v0.13.0-aarch64-apple-darwin.tar.gz' -O - | tar xz
mv alembic-v0.13.0-aarch64-apple-darwin/alembic bin/ && rm -r alembic-v0.13.0-aarch64-apple-darwin
./setup.sh                 # empty lab, fresh netbox that describes the network
```

`LAB_KEY=<path>` sets the ssh identity if the ssh config does not. run
`./setup.sh` again after a rehearsal.

## on stage

one script per step. each prints its commands.

**0.** the network is in netbox (http://localhost:8018/dcim/cables/); the lab
is empty.

**1. `./deploy`.** plans and applies `19 to create`.

**2. `./pull-cable c1`.** deletes spine01's end of cable `c1`:

```text
pull cable c1 at spine01 e1-1
denog-lab$ sudo docker exec clab-denog-spine01 ip link delete e1-1
```

**3. `./drift`.** exits 2:

```text
drift report: 0 changed, 0 missing, 1 extra

extra (present in backend, not declared in intent):
  dcim.cable {"label":"c1"}
matching: 0 by state, 27 by key (27 adopted), 0 to create
```

**4. `./deploy` again.** `1 to create`, cable `c1`.

**5. `./monitor`.** every device becomes a ping target. grafana on the lab
host, port 3000, shows the four nodes as reachable.

**6.** the plugin's backends at http://localhost:8018/plugins/alembic/backends/:
eleven targets, listed only.

## files

- `lab.yaml`: the lab, used to seed netbox.
- `schemas/`, `maps/`, `backends/`: what alembic reads, how it maps, where it
  writes.
- `netbox/`: the netbox image with the plugin and the backends it lists.
- `monitoring/`: the monitoring stack.
- `deploy`, `pull-cable`, `drift`, `monitor`: the steps. `teardown` empties
  the lab.
