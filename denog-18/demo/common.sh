# shared by the demo steps.
#
#   LAB_HOST     ssh host that runs containerlab (default: denog-lab)
#   LAB_KEY      ssh identity for it, when the ssh config does not set one
set -eu
cd "$(dirname "$0")"
[ -s .state/netbox-token ] || { echo "no netbox token; run ./setup.sh first" >&2; exit 1; }
export NETBOX_TOKEN="$(cat .state/netbox-token)"
# silences import's warnings about unmapped netbox fields
export RUST_LOG=error
LAB_HOST="${LAB_HOST:-denog-lab}"

# a step: title, command, output
step() { printf '\n\033[1m%s\033[0m\n' "$1"; shift; printf '$ %s\n' "$*"; "$@"; }

# a command on the lab host
lab() {
  printf '%s$ %s\n' "$LAB_HOST" "$*"
  ssh -T -o BatchMode=yes ${LAB_KEY:+-i "$LAB_KEY" -o IdentitiesOnly=yes} "$LAB_HOST" "$@"
}
