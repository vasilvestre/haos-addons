#!/usr/bin/env bashio
# Entry point: turn the app's options into the environment the dashboard
# reads, then hand the process over. Everything that outlives a restart lives
# under /data: the database, the secret that encrypts the stored credentials,
# and the SSH key used to reach the boxes.
#
# Options are read from /data/options.json with jq rather than through
# bashio::config: the dashboard starts the same way outside the Supervisor,
# which makes the image testable with plain docker run.
set -uo pipefail

readonly DIR=/data/pmss
readonly OPTIONS=/data/options.json
mkdir -p "${DIR}/data" "${DIR}/ssh"

option() {
    jq --raw-output "$1 // \"\"" "${OPTIONS}" 2>/dev/null || true
}

# The secret encrypts the box credentials in the database. It must survive
# restarts and never leave this directory, so it is generated once and never
# printed: losing it means re-entering every credential.
if [ ! -s "${DIR}/secret" ]; then
    head -c 32 /dev/urandom | base64 > "${DIR}/secret"
    echo "generated a new credential secret in ${DIR}/secret"
fi
chmod 600 "${DIR}/secret"

KEY="${DIR}/ssh/id_ed25519"
SSH_KEY="$(option '.ssh_key')"
if [ -n "${SSH_KEY}" ]; then
    printf '%s\n' "${SSH_KEY}" > "${KEY}"
    chmod 600 "${KEY}"
elif [ ! -s "${KEY}" ]; then
    echo "warning: no ssh_key option set, boxes that need key authentication will not answer"
fi

# The dashboard refuses to be framed, so Home Assistant ingress cannot show
# it. The app is opened from its own page instead, on its own port.
LOGIN="$(option '.login')"
if [ -n "${LOGIN}" ]; then
    printf '%s' "${LOGIN}" > "${DIR}/auth"
    chmod 600 "${DIR}/auth"
    export PMSS_AUTH_FILE="${DIR}/auth"
else
    echo "warning: no login option set, the dashboard will accept anyone who reaches it"
fi

HOSTS="homeassistant,homeassistant.local,localhost,vasilvestre.duckdns.org"
EXTRA="$(option '.allowed_hosts')"
if [ -n "${EXTRA}" ]; then
    HOSTS="${HOSTS},${EXTRA}"
fi

TZ_VALUE=""
if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
    TZ_VALUE="$(bashio::info.timezone 2>/dev/null)" || TZ_VALUE=""
fi
export TZ="${TZ_VALUE:-UTC}"

export PMSS_LISTEN="0.0.0.0:8080"
export PMSS_DATA="${DIR}/data"
export PMSS_SECRET_FILE="${DIR}/secret"
export PMSS_SSH_KEY="${KEY}"
export PMSS_ALLOWED_HOSTS="${HOSTS}"

echo "starting pmss-fleet-manager on ${PMSS_LISTEN}, data in ${PMSS_DATA}"
exec /usr/bin/pmss-fleet-manager
