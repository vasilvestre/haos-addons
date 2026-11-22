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

Open it from its own page in the app store, or directly on
`http://<home-assistant-ip>:8099/` from a phone or another computer.

The dashboard sends `frame-ancestors 'none'`, so it cannot be embedded: there is
no sidebar panel and no ingress, and the app opens in its own tab. Port 8099 is
used because 8080 on a Home Assistant box is often taken.

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

`.github/workflows/track-upstream.yaml` checks the upstream releases once a
day at 05:17 UTC and on demand from the Actions tab. When a newer tag exists, it
writes that version into `pmss-fleet-manager/config.yaml` and the matching image
tag into the `Dockerfile`, then commits and pushes. Home Assistant then shows the
app as updatable; nothing builds here, the Supervisor builds it.

Run it by hand with:

```bash
gh workflow run track-upstream.yaml --repo vasilvestre/haos-addons
gh run list --repo vasilvestre/haos-addons --limit 1
```

Add-on-only fixes need a version above the current one, since the Supervisor
compares versions and not commits. Use the next patch, or append a fourth
number.
