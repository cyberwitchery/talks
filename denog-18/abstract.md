# Network Automation for the Modern Age

In the last two decades network automation has gone from a fringe concept reserved for global players to the industry standard at almost every system size. The tooling and concepts have evolved and grown, and an ecosystem has formed and normalized around a few core systems.

In this talk, we want to propose a natural next step in the evolution from manual work over templating to driving the system with sources of truth. As the technological and business complexity of networks grows, the data model becomes more and more of a focal point of how we look at the reality of our system. We need to understand our data and our models better than ever before, and make our decisions based on how we model the world, without being constrained by the limits of our pre-fabricated documentation systems.

We will speak about what it means for an automation to be driven by your actual data model and how you conceptualize the network, motivated by an actual software system. Over the course of the talk, we will not just talk about concepts, but anchor our ideas in concrete implementation.

Nonetheless, this is not a talk about a solution. It’s a talk about an idea and an approach, and, hopefully, the start of a conversation.

The talk builds on our previous work and talks around network automation and data modeling. We want to make the case that “source of truth” is a useful step, but not the end state: the more interesting question is whether the model itself can become the driver of automation.

The talk will use alembic (https://github.com/cyberwitchery/alembic) as the concrete anchor. We plan to show how a model-first system can represent network concepts, derive operational artifacts, and fit alongside existing DCIM/IPAM/source-of-truth tools without being constrained by their object model.

Expected structure:

- short history: from manual work to templates to source-of-truth automation
- why we end up with our own data model most of the time and what that means
- concrete examples from alembic
- trade-offs, open questions, and caveats

The talk is intended for network engineers, automation engineers, and people maintaining source-of-truth or orchestration systems.
