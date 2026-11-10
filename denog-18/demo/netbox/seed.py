"""the backends the plugin lists. run with `manage.py shell`."""

from netbox_alembic.models import Backend

BACKENDS = [
    ("netbox", "netbox", {"url": "http://netbox:8080"}, "this netbox"),
    ("nautobot", "nautobot", {"url": "http://nautobot.invalid"}, "another source of truth"),
    ("infrahub", "infrahub", {"url": "http://infrahub.invalid"}, "another source of truth"),
    ("peeringdb", "peeringdb", {}, "peering data, read-only"),
    ("lab", "containerlab", {}, "the lab, driven live"),
    ("monitoring", "prometheus", {}, "prometheus file_sd targets"),
    ("ansible", "ansible", {}, "an ansible inventory"),
    ("nornir", "nornir", {}, "a nornir inventory"),
    ("dns", "dns", {}, "a bind zone"),
    ("fabric", "avd", {}, "an arista avd project"),
    ("diagram", "mermaid", {}, "a mermaid diagram"),
]
for name, kind, config, description in BACKENDS:
    backend = Backend(name=name, kind=kind, config=config, description=description)
    backend.full_clean()
    backend.save()
print(f"SEEDED {Backend.objects.count()} backends")
