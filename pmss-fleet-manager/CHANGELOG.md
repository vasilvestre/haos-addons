# Changelog

Store versions count our own publications. An entry names the upstream release
when it changed.

## 1.25.0.1

- Carries upstream `1.25.0`: [release notes](https://github.com/AlteredParadox/pmss-fleet-manager/releases/tag/v1.25.0).

## 1.24.0.6

- The store version counts our own publications on top of the upstream release,
  instead of following the image tag.

## 1.24.5

- Republishes 1.24.4 under a new store version, so Home Assistant offers the
  update.

## 1.24.4

- Image pinned to the upstream release it came from, instead of the moving
  `latest` tag.
- Direct access moved to port 8099, because 8080 is often taken on a Home
  Assistant box.

## 1.24.3

- The `webui` link opens the app's own port.

## 1.24.2

- The dashboard opens in its own tab on its own port, without ingress: it
  refuses to be framed.

## 1.24.1

- The app listens on port 8088.

## 1.24.0

- First publication, carrying upstream `1.24`: [release notes](https://github.com/AlteredParadox/pmss-fleet-manager/releases/tag/v1.24.0).
