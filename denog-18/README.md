# denog 18

"network automation for the modern age": data-model-driven network
automation, from manual work over sources of truth to putting your own data
model in the middle, with every operation (deploy, drift detection,
migration) as a transform into or out of it. alembic is the case study, with
a live demo of deploying a containerlab lab from netbox and detecting drift on
the way back.

see [the abstract](./abstract.md) and [the demo](./demo/README.md).

## build

    make

produces `talk.pdf` (31 slides). requires `xelatex`, the cyberwitchery
beamer theme (`beamerthemeCyberwitchery.sty` on the TEXINPUTS path), and
the jetbrains mono / hanken grotesk fonts.

## presenting

the demo follows the "→ live" slide in the alembic section. its steps are in
[the demo](./demo/README.md).
