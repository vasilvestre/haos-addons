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

The app appears in the sidebar as **PMSS Fleet**. It also answers on
`http://<home-assistant-ip>:8088/` for a phone or a browser outside Home
Assistant.

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
