# denog 18

"network automation for the modern age": data-model-driven network
automation, from manual work over sources of truth to putting your own data
model in the middle, with every operation (deploy, drift detection,
migration) as a transform into or out of it. alembic is the case study, with
a live demo of deploying a containerlab lab from netbox and detecting drift on
the way back.

see [the abstract](./abstract.md), [the notes](./notes.md) and
[the demo](./demo/README.md).

## build

    make

produces `talk.pdf` (31 slides). requires `xelatex`, the cyberwitchery
beamer theme (`beamerthemeCyberwitchery.sty` on the TEXINPUTS path), and
the jetbrains mono / hanken grotesk fonts.

## presenting

    make && open talk.pdf

there is exactly **one** live context switch: the demo, after the "demo
time!" slide in the alembic section. it's flagged by a full-bleed cue slide
(a big "→ live") so it reads from the back of the room. cmd+tab between the
terminal and the pdf for that segment. the commands and the output to expect
are in [the demo](./demo/README.md).
