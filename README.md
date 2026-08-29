# Dell-G15-Controller

A simple GUI app (written with PySide6/Qt) to control **keyboard backlight**, **power mode** and **fan speed** on Dell G15 (5520 and 5525) laptops.

Untested on other laptops, but the keyboard part will most likely work on any model exposing the `ID 187c:0550 Alienware Corporation LED controller` USB device. The power/fan functions are specific to the Dell G15 5520/5525 but may work on similar models.

By default, LEDs flash red on low battery and drop to half brightness on battery. Only static color and morph modes are supported at this time.

**Use at your own risk.**

## Requirements

- An `acpi_call` kernel module (for power mode / fan / G-mode control via `/proc/acpi/call`)
- A udev rule + membership of the `plugdev` group (for USB keyboard backlight control)
- Polkit (the app elevates privileges via `pkexec`)
- Python with `PySide6`, `pexpect` and `pyusb`

## Installation

### NixOS (flake) — recommended on Nix

This repo is a flake exposing a package, a NixOS module, and a dev shell.

**Try it once, without installing:**

```bash
nix run github:revoltez/Dell-G15-Controller
```

**Install persistently via the NixOS module.** The module wires up everything from the Requirements list for you (udev rule, `plugdev` group, `acpi_call`, polkit).

Add the input to your `flake.nix`:

```nix
inputs.dell-g15-controller = {
  url = "github:revoltez/Dell-G15-Controller";
  # optional: build against your own nixpkgs
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import the module into your host and enable it:

```nix
{ inputs, ... }:
{
  imports = [ inputs.dell-g15-controller.nixosModules.default ];

  programs.dell-g15-controller = {
    enable = true;
    users = [ "your-username" ]; # added to the plugdev group
  };
}
```

Then `sudo nixos-rebuild switch`. Log out and back in once so the `plugdev`
group takes effect, then launch **"Dell G15 Controller"** from your app menu
or run `dell-g15-controller`.

> Tip: if `nix` fails with a GitHub API rate-limit (HTTP 403), use the plain
> git URL instead — `url = "git+https://github.com/revoltez/Dell-G15-Controller";`

### Manual (other distributions)

1. Create the udev rule `/etc/udev/rules.d/00-aw-elc.rules`:

   ```
   SUBSYSTEM=="usb", ATTRS{idVendor}=="187c", ATTRS{idProduct}=="0550", MODE="0660", GROUP="plugdev", SYMLINK+="awelc"
   ```

2. Make sure your user is in the `plugdev` group, then reboot (or reload udev and re-login).

3. Install the Python dependencies:

   ```bash
   pip install PySide6 pexpect pyusb
   ```

4. Install and load the `acpi_call` module (see https://github.com/nix-community/acpi_call or your distro's package, e.g. `acpi-call-dkms`):

   ```bash
   sudo modprobe acpi_call
   ```

Polkit is required for the power and fan functionality.

## Usage

```bash
python main.py
```

- **Keyboard backlight:** choose red, green and blue levels, pick a mode, and press *Apply*. Use the system-tray icon to toggle the backlight quickly. Choose *Off* as the mode to clear the animation (after which AWCC can be used again).
- **Power control:** pick a power mode first; fan boost levels can then optionally be set. Fan RPM and temperatures are polled every second.

## Development

A dev shell with all dependencies is provided:

```bash
nix develop        # then: python main.py
```

(A legacy `shell.nix` is also available for non-flake `nix-shell` users.)

## Screenshots

![](window.png)

## License

GNU General Public License v3 — see [LICENSE.md](LICENSE.md).

## Contributions

Written using the information and code from https://github.com/trackmastersteve/alienfx/issues/41.

Many thanks to @AlexIII and @T-Troll for their help with the ACPI calls.
