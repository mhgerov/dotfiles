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
2. Still nothing, or a panel is dark while everything *looks* fine (see
   *Failure mode 2*) → force that output's link to retrain. From a TTY, with
   `DISPLAY=:0 XAUTHORITY=/run/lightdm/$USER/xauthority` exported:
   ```
   xrandr --output DP-2 --off
   xrandr --output DP-2 --auto
   autorandr --load desktop-4k --force
   ```
   The keybind now does this automatically, so you should rarely need it by hand.
3. Still nothing → power-cycle the monitor itself (not the PC). The panel may be
   latched in its own power-save state.
4. Only then reboot.

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
| Board / model | PowerSpec, MSI PRO B650-P WIFI (MS-7D78) | Acer Aspire A515-57 |
| CPU | AMD Ryzen 7 7800X3D | Intel Core i5-1235U |
| GPU | NVIDIA RTX 4070 SUPER (AD104), 12 GB | Intel Iris Xe (integrated) |
| Driver | **`nvidia` 580.178.04** (open kernel modules) | `i915` |
| Displays | 2x ViewSonic VX3276-UHD 4K@60 — **DP-0** right (primary), **DP-2** left | built-in panel, **eDP-1**, 1920x1080 |
| Outputs | DP-0, DP-2 real; HDMI-0, DP-1, DP-3/4/5 phantom | eDP-1, HDMI-1, DP-1, DP-2 |
| Internal panel | **none** | yes — always there |

**The boot drive:** Transcend TS256GMTE712P NVMe in a Realtek RTL9210 USB
enclosure, appearing as `/dev/sda`. Btrfs with `compress=zstd:1`, root on the
`root` subvolume, `/home` on the same device.

Note the connector names differ between machines **and between drivers**. The
switch from `nouveau` to `nvidia` renamed the desktop's outputs from
`DP-1`/`DP-2` to `DP-0`/`DP-2`, and added phantom `HDMI-0`, `DP-1`, `DP-3/4/5`
entries that are permanently disconnected. Never hardcode an output name in a
script — always read them from `xrandr --query`.

### Booting the desktop

| Entry | Kernel | Graphics | Use |
|---|---|---|---|
| default | **7.2.4** | `nvidia` (module built for this kernel only) | normal |
| fallback | **7.1.13** | `nouveau` (blacklist args removed by hand) | if nvidia breaks |

The nvidia kernel module is built by `akmods` **per kernel**, and only 7.2.4 has
`kernel-devel` available, so only 7.2.4 has it. On a kernel update, check the
module exists *before* rebooting:

```bash
ls /lib/modules/$(uname -r)/extra/nvidia/    # after: sudo akmods --force
```

**There is no boot splash any more, and that is normal.** The nvidia driver is
deliberately kept out of the initramfs (`/usr/lib/dracut/dracut.conf.d/99-nvidia-dracut.conf`),
and `nouveau`/`nova_core` are blacklisted on the kernel command line, so early
boot has **no GPU driver at all** — nothing can draw the PowerSpec or Fedora
loading screen. The machine sits apparently dead for a while and then the
desktop appears. This looks exactly like a failed boot and is not one. Boot was
left verbose (`rhgb quiet` removed) precisely so there is *something* on screen
during that gap.

If a boot genuinely fails: hold `Shift` / tap `Esc` at GRUB and pick the 7.1.13
entry, which runs `nouveau` exactly as before the switch.

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

There are **two** distinct failure modes here. Both end with a dark panel, but
they have different causes and the second one lies to every diagnostic.

### Failure mode 1: zero enabled CRTCs

Counter-intuitive, because the computer is perfectly healthy while every screen
is dark.

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

### Failure mode 2: everything reports healthy, panel still dark

Found by physically unplugging one monitor and plugging it back in — a real
hotplug, which `xrandr --output ... --off` cannot simulate.

On replug, autorandr's udev hook fired correctly and restored `desktop-4k`.
`xrandr` showed both outputs connected at the right positions. The kernel agreed
— `status=connected`, `enabled=enabled`, `dpms=On` for both. **And the left
panel showed "No Signal" anyway.** The CRTC was armed; the DisplayPort link had
never come up.

This is worse than a plain blackout, because every diagnostic lies to you:

- `autorandr --change` reports `Config already loaded` and does nothing.
- Any script checking "how many outputs are enabled?" sees the correct answer
  and concludes there is nothing to fix.

What fixes it is tearing the CRTC down and rebuilding it, which forces the link
to retrain:

```bash
xrandr --output DP-2 --off
xrandr --output DP-2 --auto
```

Doing that produced the first hard evidence against `nouveau`:

```
nouveau 0000:01:00.0: gsp: cli:0xc1d00001 obj:0x00730000 ctrl cmd:0x00731341 failed: 0x00000025
```

A GSP display control command failing. Note it is **intermittent**: it appeared
during one forced modeset but not during a later recovery of the same fault, so
it is not a required part of the failure. The silent failure itself logs nothing
at all, which is why the original incident showed a clean kernel log.

**Correction to the original diagnosis.** The first analysis concluded `nouveau`
was not at fault, reasoning from the absence of kernel errors during the
original incident. That reasoning was wrong: this failure mode is silent by
nature, so a clean log was never evidence of a healthy driver. The missing
RandR client was real and worth fixing, but `nouveau`'s display path is also
implicated. See *Known issues*.


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
| `desktop-4k` | dual 4K — `DP-0` right (primary), `DP-2` left, both 3840x2160@60 |
| `laptop-solo` | built-in panel only, 1920x1080 |

**Connector names changed with the driver switch, and `match-edid` absorbed it.**
Going from `nouveau` to `nvidia` renamed `DP-1` to `DP-0`. autorandr matched the
saved profile anyway and reported `desktop-4k: renaming display DP-1 to DP-0`.
The profile has since been re-saved under the new names. This is the payoff for
`match-edid=1` — without it the profile would simply have stopped matching.

**Two identical monitors.** Both panels are the same model (ViewSonic
VX3276-UHD, product 20792), distinguishable only by serial — `DP-0` is
VSY211500285, `DP-2` is VSY211500219. Their EDIDs therefore differ and
`match-edid` can tell them apart. If you ever add a third identical panel whose
serial is blank or duplicated, `match-edid` could swap screens; check with
`cat ~/.config/autorandr/desktop-4k/setup` and confirm the EDID strings differ.

**Watch the `primary` flag before saving.** It can strand itself on a
disconnected output — it was sitting on `HDMI-1` (nothing plugged in) when
`desktop-4k` was first saved under `nouveau`, which would have baked that into the profile.
`launch.sh` has a fallback for this, but it means polybar guesses instead of
knowing. Check with `xrandr --query | grep primary` and fix with
`xrandr --output DP-0 --primary` before `--save`.

This bit twice: the primary flag stranded itself on a disconnected output again
immediately after the nvidia switch, this time on `HDMI-0`.

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

`~/.local/bin/display-reset` — tries progressively blunter things, and logs
every step because you can't see the screen while it runs:

1. `xset dpms force on` — wake monitors out of power-save.
2. `xrandr --query` — force a fresh re-probe of what's connected.
3. **Cycle every connected output off and back on.** This is the step that
   actually works, and the reason is in *Failure mode 2* above: the script must
   never trust the reported state. Done one output at a time so a working
   screen is never dark all at once.
4. `autorandr --load <detected profile> --force` — put positions and the
   primary flag back. `--force` is essential; without it autorandr skips the
   work believing the config is already correct.
5. `xrandr --auto` — if the profile left nothing enabled.
6. Enable each connected output by hand, retrying with an explicit framebuffer
   size if X rejects the layout.
7. Restore wallpaper (`~/.fehbg`) and relaunch polybar.

It reports "**re-armed** N outputs", not "recovered" — whether a picture
actually reaches the panel is not something any of this can observe.

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

Open items. General workstation tasks live in `~/docs/TODO.md`.

- [x] ~~Save the desktop display profile.~~ Done, and re-saved after the driver
      switch renamed the connectors.

- [x] ~~Verify the `Super`+`Shift`+`D` keybind, including against failure
      mode 2.~~ Done under `nouveau`: on replug autorandr reported `Config
      already loaded` with both outputs enabled while the panel stayed dark, and
      the keybind cycled both CRTCs and brought the picture back.

- [x] ~~Decide on the GPU driver.~~ Done 2026-09-10 — switched to proprietary
      NVIDIA. See *Known issues*.

- [ ] **Re-test both display failure modes under `nvidia`.** Everything known
      about failure modes 1 and 2 was learned on `nouveau`, and failure mode 2
      was a `nouveau` display-path bug. It may simply not exist any more, or it
      may present differently. Until this is retested, the failure-mode sections
      above describe the *old* driver's behaviour. Unplug and replug a monitor
      and see what actually happens now.

- [ ] **Confirm the Intel laptop still boots.** The nvidia packaging *looks*
      harmless to it — nvidia is omitted from the initramfs and the Xorg snippet
      is conditional on `nvidia-drm` being bound — but that is read from the
      packaging, not observed. Verify on the next laptop boot, and check
      `~/.config/autorandr` still picks `laptop-solo`.

- [ ] **Optional: enable VA-API decode in Firefox.** `libva-nvidia-driver` is
      installed and `vainfo` shows NVDEC working, but Firefox does not use it
      without `media.ffmpeg.vaapi.enabled`, plus `LIBVA_DRIVER_NAME=nvidia` and
      `MOZ_DISABLE_RDD_SANDBOX=1` in the environment — its decoder sandbox
      blocks the NVIDIA driver. Would cut CPU further on 4K AV1. Playback is
      already acceptable without it.

- [ ] **Re-tune picom now the GPU can keep up.** `dual_kawase` blur at strength
      3 across 7680x2160 measurably contributed to the stutter under `nouveau`.
      A properly clocked 4070 SUPER should absorb it, but it has not been
      A/B tested since the switch.

- [ ] **Soak test the automatic path.** Leave the desktop idle long enough for a
      monitor's own DisplayPort power-save to trigger and confirm it wakes with
      no keystroke.

- [ ] **Decide whether to restore `rhgb quiet`.** Boot is currently verbose. Left
      that way deliberately: there is no splash under this setup regardless (see
      *Booting the desktop*), so verbose at least puts something on screen during
      the long black gap instead of looking like a dead machine.

---

## Known issues and open decisions

### GPU driver: switched from nouveau to proprietary NVIDIA

**Done — 2026-09-10.** Running `nvidia` 580.178.04 with the **open kernel
modules** (`license: Dual MIT/GPL`), from RPM Fusion nonfree.

Note RPM Fusion ships no `akmod-nvidia-open` package; there is one `akmod-nvidia`
which builds the open modules by default on Turing and newer. Confirm which you
actually got with `modinfo nvidia | grep license` — `Dual MIT/GPL` is open,
`NVIDIA` is the classic closed module.

Installed: `akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver libva-utils`.
The VA-API package is called **`libva-nvidia-driver`**, not `nvidia-vaapi-driver`.

**Why it was worth doing.** Two problems, both measured rather than assumed:

- *Video stutter.* CPU was never the bottleneck — 66% total across 16 cores with
  the video playing, load 1.59, Firefox's decoder process at 3.3%. The stutter
  was GPU-bound: `nouveau` could not clock the Ada card properly, so compositing
  7680x2160 starved. `nvidia-smi` now reports a range of 420 MHz idle to a
  3105 MHz ceiling, with real power states. Playback is visibly better.
- *Display stability.* Failure mode 2 above is a `nouveau` display-path bug.

Hardware video decode also came back: `vainfo` reports the NVDEC backend with
H264, HEVC (Main/Main10/Main12/444), VP9 and **AV1** — AV1 matters because
YouTube serves it for most 4K, and `nouveau` had no hardware decode path at all.

**What the install got wrong, for next time.** It did not go smoothly and none
of it was visible in the dnf output:

1. `akmods` built the module for **7.2.4** while the running kernel was
   **7.1.13** — dnf pulled `kernel-devel` for the newest kernel, not the running
   one. Rebooting then would have given no driver.
2. `kernel-devel-matched` dragged in a **partially installed 7.2.4** (no
   `kernel-modules`, no `kernel` metapackage) as a side effect, and made it the
   default boot entry.
3. The install added `rd.driver.blacklist=nouveau,nova_core` to **every** boot
   entry, including the older kernels that have no nvidia module — silently
   destroying the fallback. Fixed by hand:

   ```bash
   sudo grubby --update-kernel=/boot/vmlinuz-7.1.13-100.fc43.x86_64 \
     --remove-args="rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"
   ```

   **Always verify with `sudo grubby --info=ALL` that a working fallback entry
   still exists before rebooting into a new driver.**

**The dual-machine SSD turned out fine.** nvidia is omitted from the initramfs,
and the Xorg snippet uses `OutputClass` with `MatchDriver "nvidia-drm"`, so it
only applies where the nvidia kernel driver is actually bound. On the Acer,
`i915` drives `eDP-1` and the nvidia module never binds.

**Still open:** whether the Intel laptop really is unaffected — verified by
reading the packaging, not yet by booting it. Check on the next laptop boot.

### Note on this document

Lives at `~/docs/Desktop.md` and is tracked in the dotfiles repo, so it travels
with the config. After editing it:

```bash
dotfiles add docs/Desktop.md
dotfiles commit -m "docs: ..."
```

Keep it current when the setup changes — a stale manual is worse than none,
because you will trust it.
