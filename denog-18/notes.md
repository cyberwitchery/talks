# data-model-driven automation

## how we got here

**by hand**
- this is where we all started: ssh into the box, type the config, hope.
- we fat-fingered things all the time, and usually found out later than we
  would have liked.
- and we forgot. what we did, and more importantly why. the network was the
  only record of itself.

**write it down, then script it**
- so we started writing it down. one source of truth, or, if we're honest, often
  more than one.
- once it was written down, we could write small automations against it:
  ansible playbooks, templates that read from netbox and push config out.
- this was a real step forward, and i think it's where most of us are today.
  nothing in this talk is meant to say that was wrong.

**what that left us**
- but look at what we ended up with: a row of good systems, each doing its job.
- the code in the middle is bespoke. every pair of systems that needs to talk
  gets its own script, written by whoever needed it at the time.
- the systems don't really talk to each other. the scripts do.
- and we bend. the source of truth comes with an object model, and our
  network has to fit into it, whether or not that's how we think about it.

**the vendor answer**
- the traditional answer to this is to buy another box.
- it talks to the vendor's own stack, and to the systems they have blessed.
- and to be fair, inside that world the interoperability is excellent.
- outside it, you're back to writing glue, now with one more box to glue.

## our own model

**the model we actually work from**
- if you ask a network team what their model of the network is, the honest
  answer is rarely "whatever netbox says".
- it's the object model of the source of truth, plus custom fields and
  plugins, plus the spreadsheet next to it, plus the concepts that only exist
  in people's heads.
- i think most of us end up with our own model anyway. the question is only
  whether we admit it.

**an example**
- here's one we'll see again in the demo: a lab node.
- to run a node in containerlab you need a kind, an image, and a command.
  netbox has device types and platforms, but none of those three.
- so in practice they end up in custom fields, in config contexts, or
  hardcoded in the script that builds the lab.
- in our own model they're just fields on the device, next to the name.

**the model is already there**
- every integration we write already makes modelling decisions: what a device
  is, which fields matter, which values are valid, what gets dropped on the way.
- so the model exists. it's spread across a dozen scripts, and nobody wrote it
  down.
- that's the starting point for the rest of the talk: what if we wrote it
  down, and made it the centre?

## the model in the middle

**a different centre**
- the proposal is simple to state: put the data model you need in the
  middle, and treat every system as something you transform into and out of.
- your model, not the vendor's, and not the source of truth's.

**one transform per system**
- on the left is what point to point looks like. every system that needs to
  talk to another gets its own integration. that's n times m.
- on the right, every system talks to the model. you write one transform per
  system, once.
- that's a cost, but you pay it once per system. the alternative is paying it
  for every pair.
- adding a new system means one transform in and one out, not one for every
  system you already own.

**every operation is a transform**
- this is the part i find most interesting: once the model is in the middle,
  the operations we usually think of as different things become the same thing.
- deploying is moving data from netbox into containerlab, ansible,
  prometheus.
- drift detection is the inverse path: from containerlab back to netbox. if
  the real world and the source of truth disagree, the transform shows you where.
- migration is moving data from one source of truth to another. and because
  it's just a transform, you can run both side by side for a while, get a feel
  for the new system, and then make the actual cut over.
- same model, same engine. only the direction changes.

**a compiler for your infrastructure**
- if you've ever looked at a compiler, this shape will look familiar.
- many frontends, many backends, and some systems are both. what holds it
  together is the representation in the middle: the data and its types.
- so what you need is not another box. it's a system that is good at defining
  data models and transforming between them.

## alembic

**a case study**
- alembic is our attempt at this idea. we built it to see whether the idea holds
  up in practice.
- it's open core: the model, the engine, and the adapters for the main dcim
  and ipam systems are apache-2.0. the adapters for fabric and ops are
  commercial.
- i want to be clear that it's a case study, not the answer. you could build
  the same idea differently, and i'd like to hear about it if you have.

**set the shape once**
- this is what a model looks like. you describe your types and fields in yaml.
- references between objects use stable ids that belong to the model, never
  the ids a backend hands out. that's what lets the same model move between
  systems.

**nothing changes by surprise**
- reading, mapping and planning never write anything.
- the plan tells you what would happen. apply is the only step that writes,
  and it applies exactly the plan you looked at.
- for a network team i think that's the most important property: nothing is
  written before you see the plan.

**the demo**
- the setup: netbox on one side, a containerlab lab on the other.
- first we deploy: netbox to containerlab.
- then i'll change something in the lab by hand, and run the inverse path,
  containerlab to netbox, to show the drift.

**live: deploy, then drift**
- netbox first: four devices, five cables. the lab is empty.
- deploy: import from netbox, map into the lab's model, plan. the plan is 19
  creates: four nodes, ten interfaces, five links. apply, and the lab is up in
  about fifteen seconds.
- the map is where the example from earlier lives: the device type decides the
  image, the kind and the command.
- now someone pulls a cable: delete one link in the running lab, by hand.
- drift: the same steps the other way round. import from the lab, map into
  netbox's model, and ask how netbox differs. one extra cable: netbox still has
  `c1`, the lab doesn't.
- and since netbox is still the intent, the forward path puts it back: one
  create, apply, done.
- same engine, same maps, three operations. only the direction changed.

## trade-offs

**you own the engineering**
- this is the honest trade-off, and i don't think it goes away.
- if you go all in on a vendor, you get excellent interoperability out of the
  box. you also get their model, and the systems they have blessed.
- if you own the model, you get the shape you actually need. but you
  necessarily make more decisions, and you own them.
- which side of that is right depends on your network and your team. i'd argue
  more teams are already on the second side than they think, they just haven't
  written it down.

**reinventing the universe**
- the second trade-off: a bespoke model often means reinventing the universe.
  every concept a source of truth gives you for free, you now have to model
  yourself.
- alembic tries to make that easier, with an expressive model and cookbooks
  and recipes to start from instead of a blank page.
- but it's a real problem. it can get teams stuck in design phase limbo,
  modelling forever and never moving any data.

**it only pays off at a certain size**
- and i think we have to be honest about this: it probably only makes sense
  at a certain size.
- that size gets smaller and smaller as the tools get better. but it isn't
  zero, and for a small network a source of truth and a few playbooks may be
  exactly right.

**not another box**
- if you own the model, the transforms get easier.
- alembic is not another box in the diagram. it's the edges between them.
- this is meant to be the start of a conversation, so i'd love to hear how
  you model your network, and where it breaks.
