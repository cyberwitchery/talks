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
  and alembic 0.13.0 at `bin/alembic`, the version the adapter is built
  against.

the containerlab adapter is part of the commercial alembic-ops layer, so it is
not in this repo.

## setup

```sh
gh release download v0.13.0 -R cyberwitchery/alembic \
  -p 'alembic-v0.13.0-aarch64-apple-darwin.tar.gz' -O - | tar xz
mv alembic-v0.13.0-aarch64-apple-darwin/alembic bin/ && rm -r alembic-v0.13.0-aarch64-apple-darwin
./setup.sh                 # empty lab, fresh netbox that describes the network
```

every script reaches the lab host with `ssh $LAB_HOST`. `LAB_KEY=<path>`
passes an ssh identity when the ssh config does not set one. run `./setup.sh`
again after a rehearsal.

## on stage

one script per step. each prints the full command it runs, then its output.

**0. the network is in netbox.** show devices and cables at
http://localhost:8018/dcim/cables/. the lab is empty.

**1. `./deploy`.** read netbox, map it into the lab's model, plan, apply, and
show the running lab. plans `19 to create`, applies in about 15 seconds, and
ends with `containerlab inspect`: four nodes running.

**2. `./pull-cable c1`.** takes cable `c1` out of the running lab at its first
end, spine01 port e1-1:

```text
pull cable c1 at spine01 e1-1
spark$ sudo docker exec clab-denog-spine01 ip link delete e1-1
```

**3. `./drift`.** read the lab, map it into netbox's model, and compare with
netbox:

```text
drift report: 0 changed, 0 missing, 1 extra

extra (present in backend, not declared in intent):
  dcim.cable {"label":"c1"}
matching: 0 by state, 27 by key (27 adopted), 0 to create
```

it exits 2. the compare step sends stderr to `/dev/null`: `--report` saves no
state, so it would list all 27 objects it matched by key on every run.

**4. `./deploy` again.** netbox is still the intent, so the plan is `1 to
create`, cable `c1`, and the lab shows four nodes running.

## files

- `lab.yaml`: the lab in containerlab's terms, only used to seed netbox.
- `schemas/`: what each side reads, `netbox.yaml` and `lab.yaml`.
- `maps/`: `netbox-to-lab.yaml` derives a node's image, kind and command from
  its device type, `lab-to-netbox.yaml` the reverse (`transforms.star`).
- `backends/`: netbox, and the lab over ssh.
- `deploy`, `pull-cable`, `drift`: the steps, with `common.sh`. `teardown`
  empties the lab for another run.
