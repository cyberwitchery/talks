# shared by the demo scripts: run from the demo directory, with netbox's token
# and the lab host, and print every command before it runs.
#
#   LAB_HOST     ssh host that runs containerlab (default: spark)
#   LAB_KEY      ssh identity for it, when the ssh config does not set one
set -eu
cd "$(dirname "$0")"
[ -s .state/netbox-token ] || { echo "no netbox token; run ./setup.sh first" >&2; exit 1; }
export NETBOX_TOKEN="$(cat .state/netbox-token)"
# import otherwise lists every netbox field the schema leaves out
export RUST_LOG=error
LAB_HOST="${LAB_HOST:-spark}"

# a step: what it does, then the command, then its output
step() { printf '\n\033[1m%s\033[0m\n' "$1"; shift; printf '$ %s\n' "$*"; "$@"; }

# a command on the lab host, printed as it would be typed there
lab() {
  printf '%s$ %s\n' "$LAB_HOST" "$*"
  ssh -T -o BatchMode=yes ${LAB_KEY:+-i "$LAB_KEY" -o IdentitiesOnly=yes} "$LAB_HOST" "$@"
}
