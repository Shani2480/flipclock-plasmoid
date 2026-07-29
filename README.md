# Flip Clock

A split-flap flip clock widget for KDE Plasma 6, with a real two-phase flip
animation, light and dark themes, and a brass seconds sweep.

![Flip Clock](screenshots/desktop.png)

## Features

- Genuine split-flap animation — the top leaf falls forward on the seam,
  the bottom leaf drops into place behind it
- Dark, light, or follow-the-colour-scheme theming
- Seconds as a sweeping bar, a third flip card, or hidden
- 12/24 hour, optional date line
- Scales continuously — drag any resize handle and the whole composition
  follows
- Panel aware — sizes itself to the panel thickness and asks for only the
  width it actually needs, in both horizontal and vertical panels

## Install

From the KDE Store: right-click the desktop, **Add Widgets → Get New Widgets →
Download New Plasma Widgets**, then search for Flip Clock.

From a local file:

```bash
kpackagetool6 --type Plasma/Applet --install ./flipclock.plasmoid
```

To upgrade an existing install, swap `--install` for `--upgrade` and then
restart the shell:

```bash
systemctl --user restart plasma-plasmashell
```

## Configuration

Right-click the widget → **Configure Flip Clock**.

| Setting | Values | Default |
| --- | --- | --- |
| Theme | Dark / Light / Follow colour scheme | Dark |
| Seconds | Hidden / Sweeping bar / Flip card | Sweeping bar |
| 24-hour clock | on / off | on |
| Show date | on / off | on |
| Font family | any installed family | Fira Sans |

The font falls back to the Qt default if the named family is not installed.
Check what you have with `fc-list : family`.

### In a panel

The date line is hidden automatically in a panel — at typical panel
thicknesses it would leave almost no room for the cards. Everything else
works the same. In a vertical panel the cards stack instead of sitting in
a row.

## Requirements

- KDE Plasma 6
- Qt 6

## License

MIT — see [LICENSE](LICENSE).
