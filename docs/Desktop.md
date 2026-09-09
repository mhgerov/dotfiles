# Desktop Environment

Owner's manual for **hexbench** — Fedora 43 + i3, running from a portable SSD
that boots two different machines.

Config lives in the dotfiles repo (bare repo, work-tree `$HOME`). For the repo
workflow itself see `~/docs/dotfiles.md`; this document covers *operating* the
environment, not versioning it.

---

## EMERGENCY: screens say "No Signal"

**Press `Super` + `Shift` + `D`.**

That is the whole fix. The machine is still running — you can usually hear audio
still playing — and X still receives keystrokes even with nothing on screen, so
the keybinding works blind. Give it two or three seconds.

If that does nothing:

1. `Ctrl` + `Alt` + `F2` → log in at the text console → run:
   ```bash
   DISPLAY=:0 XAUTHORITY=/run/lightdm/$USER/xauthority xrandr --auto
   ```
   then `Ctrl` + `Alt` + `F1` to switch back.
2. Still nothing → power-cycle the monitor itself (not the PC). The panel may be
   latched in its own power-save state.
3. Only then reboot.

**Do not bother with `Super`+`Shift`+`R`** (i3 restart). It restarts polybar and
looks like it should help, but it never touches display configuration. It will
not fix this.

Afterwards, check what happened:

```bash
cat ~/.local/state/display-reset.log          # manual recovery (the keybind)
cat ~/.local/state/autorandr-postswitch.log   # automatic recovery (hotplug)
```

---

## The two machines

One SSD, two very different computers. The environment is identical on both;
the display hardware is not, and that difference is the whole reason the
blackout bug exists.

| | **Gaming desktop** | **Laptop** |
|---|---|---|
| Board / model | MSI PRO B650-P WIFI (MS-7D78) | Acer Aspire A515-57 |
| CPU | AMD Ryzen 7 7800X3D | Intel Core i5-1235U |
| GPU | NVIDIA RTX 4070 SUPER (AD104), 12 GB | Intel Iris Xe (integrated) |
| Driver | `nouveau` (open source) | `i915` |
| Displays | 2x ViewSonic VX3276-UHD 4K@60 — **DP-1** right (primary), **DP-2** left | built-in panel, **eDP-1**, 1920x1080 |
| Outputs | HDMI-1, DP-1, DP-2, DP-3 | eDP-1, HDMI-1, DP-1, DP-2 |
| Internal panel | **none** | yes — always there |

**The boot drive:** Transcend TS256GMTE712P NVMe in a Realtek RTL9210 USB
enclosure, appearing as `/dev/sda`. Btrfs with `compress=zstd:1`, root on the
`root` subvolume, `/home` on the same device.

Note the connector names differ between machines. Never hardcode an output name
in a script — always read them from `xrandr --query`.

---

## Display Management

### How it works

Three layers, cheapest first:

1. **autorandr + udev (automatic).** The `autorandr` package installs
   `/usr/lib/udev/rules.d/40-monitor-hotplug.rules`, which fires
   `autorandr.service` on any DRM change event. autorandr matches the connected
   monitors against saved profiles and reapplies the right layout. This handles
   the ordinary case with no input from you.
2. **`Super`+`Shift`+`D` (manual).** Runs `~/.local/bin/display-reset`. This is
   the safety net for when layer 1 doesn't fire or doesn't help.
3. **Console fallback.** The TTY commands in the emergency section above.

### Why the blackout happens

Worth understanding, because the failure is counter-intuitive — the computer is
perfectly healthy while every screen is dark.

i3 is **not a RandR client**. GNOME and KDE ship a component (mutter, kwin) that
watches for monitor hotplug events and reassigns displays automatically. i3
deliberately does not. Nothing in a bare i3 setup owns that job unless you
provide it.

So on the desktop:

1. A monitor briefly drops — its own DisplayPort power-save, or a link blip. X
   releases that output's CRTC.
2. It comes back. X re-probes it, reads its EDID, marks it connected — **and
   stops there.** Assigning a CRTC is a RandR client's job, and there isn't one.
3. If that was the last enabled output, the X screen now has **zero enabled
   CRTCs**. Every monitor reports "No Signal" while X, i3, picom and audio keep
   running normally. Hence the music.

**This is desktop-only for a structural reason.** The laptop's `eDP-1` always
holds a CRTC, so losing an external monitor can never black out everything —
there is always a surface left to fix things from. The desktop has no internal
panel, so once its last output drops there is nothing left to recover from.

**How many monitors matters.** The original total blackout happened during a
session where only `DP-1` was connected, so one drop was enough to kill
everything. With both panels attached there is redundancy — losing one leaves
the other, and you get a survivable half-broken desktop rather than a black
one. A total blackout now needs both to drop (a shared dock, a power event, or
the GPU dropping the whole link).

`nouveau` is *not* the cause — there were no kernel errors when this happened,
and the monitor's EDID read perfectly. See *Known issues* below.

### autorandr profiles

autorandr identifies hardware by **EDID** (each monitor's unique ID), not by
connector name, so both machines' profiles coexist safely in one config
directory on the shared SSD.

| Task | Command |
|---|---|
| List saved profiles | `autorandr --list` |
| Which one is active | `autorandr --current` |
| Which ones match right now | `autorandr --detected` |
| Save current layout | `autorandr --save <name>` |
| Load one by hand | `autorandr --load <name>` |
| Re-detect and apply | `autorandr --change` |
| Delete one | `autorandr --remove <name>` |
| Preview without applying | `autorandr --load <name> --dry-run` |

Current profiles:

| Profile | Layout |
|---|---|
| `desktop-4k` | dual 4K — `DP-1` right (primary), `DP-2` left, both 3840x2160@60 |
| `laptop-solo` | built-in panel only, 1920x1080 |

**Two identical monitors.** Both panels are the same model (ViewSonic
VX3276-UHD, product 20792), distinguishable only by serial — `DP-1` is
VSY211500285, `DP-2` is VSY211500219. Their EDIDs therefore differ and
`match-edid` can tell them apart. If you ever add a third identical panel whose
serial is blank or duplicated, `match-edid` could swap screens; check with
`cat ~/.config/autorandr/desktop-4k/setup` and confirm the EDID strings differ.

**Watch the `primary` flag before saving.** It can strand itself on a
disconnected output — it was sitting on `HDMI-1` (nothing plugged in) when
`desktop-4k` was first saved, which would have baked that into the profile.
`launch.sh` has a fallback for this, but it means polybar guesses instead of
knowing. Check with `xrandr --query | grep primary` and fix with
`xrandr --output DP-1 --primary` before `--save`.

**After changing a monitor arrangement, save it** — otherwise autorandr has
nothing to restore and falls back to a generic layout:

```bash
arandr                        # drag monitors into place in the GUI, apply
autorandr --save desktop-4k --force
```

Settings live in `~/.config/autorandr/settings.ini`:

- `match-edid=1` — match by monitor identity, not connector name. Means moving a
  cable to a different port still matches the saved profile.
- `default=horizontal` — if nothing matches, stack whatever is connected side by
  side at best resolution, rather than leaving the screen dark.

### What `display-reset` actually does

`~/.local/bin/display-reset` — tries progressively blunter things until
something lights up, and logs every step because you can't see the screen while
it runs:

1. `xset dpms force on` — wake monitors out of power-save.
2. `xrandr --query` — force a fresh re-probe of what's connected.
3. `autorandr --change --default horizontal` — restore the saved layout. Usual
   winner.
4. `xrandr --auto` — enable everything at its preferred mode. May overlap
   displays; the goal at this point is *a* picture, not a nice one.
5. Enable each connected output by hand, retrying with an explicit framebuffer
   size if X rejects the layout.
6. Restore wallpaper (`~/.fehbg`) and relaunch polybar.

Polybar **must** be relaunched on any display change: its bars are pinned to a
specific monitor (`monitor-strict = true`), so they vanish when the output set
changes. This is also why `~/.config/autorandr/postswitch.d/10-polybar-wallpaper`
exists — it does the same after an automatic switch.

### Adding a new monitor

```bash
# 1. plug it in, then confirm the system sees it
xrandr --query | grep ' connected'

# 2. arrange it visually and apply
arandr

# 3. save the result so it is restored automatically next time
autorandr --save <descriptive-name>
```

---

## The stack

| Piece | What it does | Config |
|---|---|---|
| **i3** 4.25.1 | tiling window manager | `~/.config/i3/config` |
| **polybar** 3.7.2 | status bar (one per monitor) | `~/.config/polybar/config.ini`, `launch.sh` |
| **picom** | compositor — transparency, shadows | `~/.config/picom/picom.conf` |
| **kitty** 0.43.1 | terminal | `~/.config/kitty/kitty.conf` |
| **rofi** | application launcher | `~/.config/rofi/config.rasi`, `augmented-amber.rasi` |
| **neovim** | editor | `~/.config/nvim/init.lua` |
| **lightdm** | login screen | `/etc/lightdm/lightdm.conf` |
| **i3lock** + xss-lock | screen lock, incl. before suspend | in i3 config |
| **feh** | wallpaper | `~/.fehbg` |
| **dunst** | desktop notifications | — |
| **autorandr** | display profile automation | `~/.config/autorandr/` |
| **PipeWire** | audio | — |
| **NetworkManager** | networking (+ `nm-applet` tray) | — |

The mod key is **`Super`** (the Windows key), set as `Mod4`.

### Keybindings

**Launching and windows**

| Keys | Action |
|---|---|
| `Super`+`Return` | new kitty terminal |
| `Super`+`D` | rofi app launcher |
| `Super`+`Shift`+`Q` | close focused window |
| `Super`+`F` | fullscreen toggle |
| `Super`+`Shift`+`Space` | toggle floating |
| `Super`+`Space` | move focus between tiling and floating |

**Focus and movement** — vim keys `h` `j` `k` `l`, arrow keys also work

| Keys | Action |
|---|---|
| `Super`+`h/j/k/l` | focus left / down / up / right |
| `Super`+`Shift`+`h/j/k/l` | move window left / down / up / right |
| `Super`+`A` | focus parent container |
| `Super`+`R` | resize mode (`h/j/k/l` to resize, `Esc` to exit) |

**Layout**

| Keys | Action |
|---|---|
| `Super`+`;` | split horizontal |
| `Super`+`V` | split vertical |
| `Super`+`S` | stacking layout |
| `Super`+`W` | tabbed layout |
| `Super`+`E` | toggle split layout |

**Workspaces**

| Keys | Action |
|---|---|
| `Super`+`1`–`0` | switch to workspace 1–10 |
| `Super`+`Shift`+`1`–`0` | move window to workspace 1–10 |

**System**

| Keys | Action |
|---|---|
| **`Super`+`Shift`+`D`** | **display recovery — fixes "No Signal"** |
| `Super`+`Shift`+`C` | reload i3 config (keeps layout) |
| `Super`+`Shift`+`R` | restart i3 in place |
| `Super`+`Shift`+`E` | exit i3 (asks first) — ends the X session |
| Volume / mute keys | PipeWire via `pactl` |
| Brightness keys | `brightnessctl` (laptop) |

### Common tasks

| Task | How |
|---|---|
| Audio mixer | `pavucontrol` (GUI) or `alsamixer` (TUI) |
| Wi-Fi / network | `nmtui`, or the `nm-applet` tray icon |
| Lock the screen | `loginctl lock-session` |
| Change wallpaper | edit `~/.fehbg` (currently `~/Pictures/Robotron-Wallpaper.png`) |
| Restart the bar | `~/.config/polybar/launch.sh` |
| Reload i3 after editing config | `Super`+`Shift`+`C` |
| Check config before reloading | `i3 -C -c ~/.config/i3/config` |

---

## Theme — Augmented Amber

Retro amber-CRT palette, amber-first with sparing semantic accents. Full spec in
`~/docs/Style-Guidelines.txt`. **Never introduce colors outside it.**

| Role | Hex |
|---|---|
| Background | `#0c0b00` |
| Panel | `#151100` |
| Panel alt | `#1d1600` |
| Foreground | `#ffd86b` |
| Muted | `#805a00` |
| Primary amber | `#ffb000` |
| Soft amber | `#ffc94d` |
| Purple (accent) | `#c792ea` |
| Cyan (accent) | `#89ddff` |
| Green (accent) | `#a3be8c` |
| Warning | `#ff8f00` |

Font throughout: **IBM Plex Mono**, size 10. Gaps: inner 12, outer 18.

---

## TODO

Open items from setting up the display recovery. General workstation tasks live
in `~/docs/TODO.md`.

- [x] ~~Save the desktop display profile.~~ Done — `desktop-4k` saved and
      verified. Recovery from an induced total blackout (both outputs dropped)
      restored both panels and the primary flag correctly, via
      `autorandr --change`.

- [ ] **Verify the `Super`+`Shift`+`D` keypress itself.** The *script* is now
      proven on both machines, including a real total blackout on the desktop.
      The *binding* has still never been fired by an actual keypress — that is
      the one untested link. On the desktop, drop both outputs with
      `xrandr --output DP-1 --off --output DP-2 --off`, then press it. Have a
      phone handy with the TTY fallback from the emergency section.

- [ ] **Soak test the automatic path.** Leave the desktop idle long enough for
      the monitor's own DisplayPort power-save to trigger, then confirm it wakes
      with no keystroke. Check `~/.local/state/autorandr-postswitch.log` and
      `journalctl -b 0 | grep -i autorandr` to see whether the udev hook fired.

- [ ] **Decide on the GPU driver** after a week or so of living with the fix —
      see *Known issues* below. No rush by design.

---

## Known issues and open decisions

### nouveau vs the proprietary NVIDIA driver

The RTX 4070 SUPER runs on `nouveau`, the open-source driver. It works — it can drive
the card at all only because NVIDIA now publishes GSP firmware — but it leaves a
lot of gaming performance unused, since clock management and the NVK Vulkan
driver still trail NVIDIA's own.

Switching to the proprietary driver (`akmod-nvidia-open` from RPM Fusion; the
card is new enough to support the open-kernel-module variant) would recover that
performance and bring more robust DisplayPort handling. The catch: it is an
out-of-tree kernel module that rebuilds on every kernel update, and a failed
rebuild means booting to no GUI — on the machine whose only display is the thing
that already breaks. The shared SSD adds risk, since the package blacklists
`nouveau` and rebuilds the initramfs on a root that also boots the Intel laptop.

In favor whenever you do it: Secure Boot is **disabled** (no module-signing
hassle, the usual failure point) and multiple kernels stay installed, so there
is a rollback path.

**Deferred deliberately.** Now that a display drop costs one keystroke instead of
a hard reboot, there is no urgency — judge the swap on gaming performance alone.

### Note on this document

Lives at `~/docs/Desktop.md` and is tracked in the dotfiles repo, so it travels
with the config. After editing it:

```bash
dotfiles add docs/Desktop.md
dotfiles commit -m "docs: ..."
```

Keep it current when the setup changes — a stale manual is worse than none,
because you will trust it.
