# a containerlab node's image is a netbox device type.
IMAGES = {
    "alpine:3": "alpine",
    "ghcr.io/nokia/srlinux:latest": "srlinux",
}

def type_slug(image):
    if image not in IMAGES:
        fail("no device type for image: " + image)
    return IMAGES[image]

# the role is the name without its number: leaf01 is a leaf.
def role(name):
    return name.rstrip("0123456789")

# and back: a device type is a node's image, its containerlab kind, and
# what it runs.
NODES = {
    "alpine": ("alpine:3", "linux", "sleep infinity"),
    "srlinux": ("ghcr.io/nokia/srlinux:latest", "nokia_srlinux", None),
}

def _node(type_slug):
    if type_slug not in NODES:
        fail("no containerlab node for device type: " + type_slug)
    return NODES[type_slug]

def image(type_slug):
    return _node(type_slug)[0]

def kind(type_slug):
    return _node(type_slug)[1]

def cmd(type_slug):
    return _node(type_slug)[2]
