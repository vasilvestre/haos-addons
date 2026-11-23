# haos-addons

Home Assistant OS apps for my own use. One repository, apps in subdirectories,
installed from the Home Assistant app store by URL.

| App | What it does |
|---|---|
| `pmss-fleet-manager` | Runs [pmss-fleet-manager](https://github.com/AlteredParadox/pmss-fleet-manager) on the Home Assistant box: one dashboard for a fleet of Pulsed Media seedboxes, read over SSH. |

## Install

1. In Home Assistant, open **Settings → Apps → App store**.
2. Open the three-dot menu, choose **Repositories**, and add
   `https://github.com/vasilvestre/haos-addons`.
3. Find **PMSS Fleet Manager** in the store and install it.
4. Fill the options (see below), then start it.

Open it from the sidebar panel, from the app page with **Open Web UI**, or
directly on `http://<home-assistant-ip>:8099/` from a phone or another computer.

The app runs behind ingress, so Home Assistant shows the dashboard in a sidebar
panel on its own origin, with the Home Assistant login. The dashboard refuses to
be framed by default; the app lifts that for the Home Assistant origin at start,
so enable **Show in sidebar** to get the panel. The direct port 8099 stays for a
reverse proxy, because 8080 on a Home Assistant box is often taken.

## PMSS Fleet Manager options

| Option | Meaning |
|---|---|
| `login` | `user:password` the dashboard asks for. Empty means no login at all, and the app warns in its log. |
| `ssh_key` | Private key used to reach the seedboxes, in OpenSSH format, pasted whole. Boxes configured with password authentication ignore it. |
| `allowed_hosts` | Extra host names the dashboard accepts, comma-separated, for example `pi.local`. IP addresses and `localhost` are always accepted. |

The box credentials typed in the dashboard stay there, encrypted with a secret
the app generates on first start at `/data/pmss/secret`. Back that file up with
`/data/pmss/data`: without it, every stored credential has to be entered again.

## Where the data lives

| Path in the app | What it holds |
|---|---|
| `/data/pmss/data` | the database |
| `/data/pmss/secret` | the key that encrypts the stored credentials |
| `/data/pmss/ssh/id_ed25519` | the SSH key from the `ssh_key` option |

Reinstalling the app keeps all of it. Uninstalling deletes it, so take a backup
with the store menu before that.

## Updating the app

The version in `pmss-fleet-manager/config.yaml` follows the upstream release it
carries. To update:

1. Change `config.yaml` `version`, and `UPSTREAM_IMAGE` in the Dockerfile.
2. Commit and push.
3. In Home Assistant, reload the store and update the app.

## Next

```bash
git clone git@github.com:vasilvestre/haos-addons.git && cd haos-addons
```

## Updates

Two numbers drive this app, and they mean different things.

**The image tag** in the `Dockerfile` names an upstream release image that
exists on `ghcr.io`:

```
ARG UPSTREAM_IMAGE=ghcr.io/alteredparadox/pmss-fleet-manager:1.24.0
```

**The store version** in `config.yaml` counts our own publications. It is the
upstream release plus a revision:

```
version: "1.24.0.6"
```

Read `1.24.0.6` as "the sixth build of this app on top of upstream `1.24.0`".
The two are kept apart on purpose:

- Upstream publishes only round tags (`1.24.0`, then `1.25.0`), so a build of
  ours that fixes a port or an option has nothing to name itself after. Bumping
  the revision says what changed; the image keeps its real tag.
- The Supervisor compares store versions, never commits. Every publish needs a
  version above the last one, and a revision always is.
- An upstream release always sorts above the revisions of the older release,
  because `1.25.0.1` is above `1.24.0.6`.

The workflow `.github/workflows/track-upstream.yaml` runs once a day at 05:17
UTC, and on demand. It compares the image tag with the newest upstream release,
never with the store version. When they differ, it pins the new image, writes
`<upstream>.1`, adds a line to `pmss-fleet-manager/CHANGELOG.md`, commits,
pushes, and tags the commit with the store version. Nothing builds here: the
Supervisor builds the image when you install the update.

For an app-only change, edit `config.yaml` yourself, raise the last number
(`1.24.0.6` becomes `1.24.0.7`), and add a line to
`pmss-fleet-manager/CHANGELOG.md`. Do not touch the image tag unless upstream
moved.

Run the workflow by hand with:

```bash
gh workflow run track-upstream.yaml --repo vasilvestre/haos-addons
gh run list --repo vasilvestre/haos-addons --limit 1
```

## What CI checks before a push reaches Home Assistant

`.github/workflows/validate.yaml` runs on every push to `main` and on every pull
request. It fails when:

1. The image tag in `ARG UPSTREAM_IMAGE` does not exist on `ghcr.io`
   (`docker manifest inspect`).
2. `version` in `config.yaml` is not `<upstream>.<revision>`, or its first three
   parts differ from the image tag.
3. `config.yaml` would be rejected by the Supervisor: bad `slug`, unknown
   `arch`, a `webui` that is not `http://[HOST]:[PORT:8080]/`, a container port
   `run.sh` does not listen on (`PMSS_LISTEN`), an `ingress_port` that is not the
   port `run.sh` listens on, or a `watchdog` port that is not the published port.
4. A change under `pmss-fleet-manager/` comes without a higher store version and
   a matching line in `CHANGELOG.md`. The error names the next version to use.
5. `run.sh` does not reach the dashboard binary, or does not export the
   environment it documents (`PMSS_LISTEN`, `PMSS_DATA`, `PMSS_SECRET_FILE`,
   `PMSS_SSH_KEY`, `PMSS_AUTH_FILE`, `PMSS_ALLOWED_HOSTS`, `TZ`).

To read a publication, two lines are enough: `version` in `config.yaml` and
`ARG UPSTREAM_IMAGE` in the Dockerfile. They always agree on the upstream part.
