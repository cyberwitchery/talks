# demo: deploy and drift

a lab described in netbox is deployed to containerlab, a link is removed from
the running lab by hand, and the inverse path (containerlab to netbox) shows
the drift. then the forward path puts the link back.

```text
netbox  → map → containerlab     deploy
netbox ← map ← containerlab      drift
```

## what runs where

- **the lab host** (`LAB_HOST`, default `spark`): containerlab and the
  containerlab adapter, at `bin/denog/alembic-adapter-containerlab`. the lab is
  `denog`: two sr linux spines, two alpine leaves, five links (`lab.yaml`).
  alembic runs the adapter over ssh (`bin/lab-adapter`).
- **this machine**: netbox 4.6.2 on http://localhost:8018 (`compose.yml`),
  and alembic 0.11.0 at `bin/alembic`, the version the adapter is built
  against.

the containerlab adapter is part of the commercial alembic-ops layer, so it is
not in this repo.

## setup

```sh
gh release download v0.11.0 -R cyberwitchery/alembic \
  -p 'alembic-v0.11.0-aarch64-apple-darwin.tar.gz' -O - | tar xz
mv alembic-v0.11.0-aarch64-apple-darwin/alembic bin/ && rmdir alembic-v0.11.0-aarch64-apple-darwin
./setup.sh                 # empty lab, fresh netbox that describes the network
export NETBOX_TOKEN=$(cat .state/netbox-token)
export RUST_LOG=error      # import otherwise lists every netbox field it drops
```

`LAB_KEY=<path>` passes an ssh identity when the ssh config does not set one.
run `./setup.sh` again after a rehearsal.

## on stage

**0. the network is in netbox.** show devices and cables at
http://localhost:8018/dcim/cables/. the lab is empty.

**1. deploy.** read netbox, map it into the lab's model, plan, apply.

```sh
bin/alembic import -f schemas/netbox.yaml --backend-config backends/netbox.yaml -o netbox.json
bin/alembic map -f netbox.json --spec maps/netbox-to-lab.yaml -o lab.json
bin/alembic plan -f lab.json --backend-config backends/lab.yaml -o plan.json
bin/alembic apply -p plan.json --backend-config backends/lab.yaml
```

```text
plan: 19 to create, 0 to update, 0 to delete
matching: 0 by state, 0 by key, 19 to create
...
applied 19 operations
```

the apply takes about 15 seconds. `sudo containerlab inspect --name denog` on
the lab host shows the four nodes.

**2. break something.** on the lab host, remove `c1` (spine01:e1-1 to
leaf01:eth1) behind everyone's back:

```sh
sudo ip netns exec clab-denog-leaf01 ip link delete eth1
```

**3. drift.** the same engine, the other direction: read the lab, map it into
netbox's model, and ask how netbox differs from it.

```sh
bin/alembic import -f schemas/lab.yaml --backend-config backends/lab.yaml -o observed.json
bin/alembic map -f observed.json --spec maps/lab-to-netbox.yaml -o drift.json
bin/alembic plan -f drift.json --backend-config backends/netbox.yaml --report 2>/dev/null
```

```text
drift report: 0 changed, 0 missing, 1 extra

extra (present in backend, not declared in intent):
  dcim.cable {"label":"c1"}
matching: 0 by state, 27 by key (27 adopted), 0 to create
```

it exits 2. `2>/dev/null` hides the 27 adopted-by-key lines, which `--report`
prints every run because it saves no state.

**4. put it back.** netbox is still the intent, so the forward path repairs it.

```sh
bin/alembic plan -f lab.json --backend-config backends/lab.yaml -o plan.json
bin/alembic apply -p plan.json --backend-config backends/lab.yaml
```

```text
plan: 1 to create, 0 to update, 0 to delete
matching: 18 by state, 0 by key, 1 to create

create:
  dcim.cable {"label":"c1"}
...
applied 1 operations
```

## files

- `lab.yaml`: the lab in containerlab's terms, only used to seed netbox.
- `schemas/`: what each side reads, `netbox.yaml` and `lab.yaml`.
- `maps/`: `netbox-to-lab.yaml` derives a node's image, kind and command from
  its device type, `lab-to-netbox.yaml` the reverse (`transforms.star`).
- `backends/`: netbox, and the lab over ssh.
