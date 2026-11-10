# alembic's netbox plugin. every file in alembic-plugins is a backend kind.
PLUGINS = ["netbox_alembic"]
PLUGINS_CONFIG = {
    "netbox_alembic": {
        "work_root": "/opt/alembic-work",
        "plugins_dir": "/opt/alembic-plugins",
    },
}
