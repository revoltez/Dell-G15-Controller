{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [
    pyside6
    pexpect
    pyusb
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dell-g15-controller";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  dontConfigure = true;
  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "dell-g15-controller";
      desktopName = "Dell G15 Controller";
      exec = "dell-g15-controller";
      icon = "dell-g15-controller";
      terminal = false;
      type = "Application";
      categories = [ "System" "Settings" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    # The app is a set of loose scripts run as `python main.py`.
    install -Dm644 *.py -t $out/share/dell-g15-controller/
    install -Dm644 window.png $out/share/pixmaps/dell-g15-controller.png

    makeWrapper ${pythonEnv}/bin/python $out/bin/dell-g15-controller \
      --add-flags $out/share/dell-g15-controller/main.py \
      --suffix PATH : /run/wrappers/bin

    runHook postInstall
  '';

  meta = {
    description = "Control keyboard backlight, power modes and fans on Dell G15 laptops";
    homepage = "https://github.com/revoltez/Dell-G15-Controller";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dell-g15-controller";
  };
})
