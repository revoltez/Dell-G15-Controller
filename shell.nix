{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.pyside6
    python3Packages.pexpect
    python3Packages.pyusb
    polkit
  ];
  shellHook = ''
    export PATH="/run/wrappers/bin:$PATH"
    export PS1="$ "
    export TERM=dumb
    export PROMPT_COMMAND=""

    if [ ! -d .venv ]; then
      python3 -m venv .venv --system-site-packages
    fi
    source .venv/bin/activate
    pip install pexpect pyusb 2>/dev/null

    sudo groupadd plugdev 2>/dev/null || true
    sudo usermod -aG plugdev $LOGNAME 2>/dev/null || true
    sudo modprobe acpi_call 2>/dev/null || true
  '';
}
