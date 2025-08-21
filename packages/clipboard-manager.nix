{
  lib,
  libcosmicAppHook,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
  inputs,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-clipboard-manager";
  version = "0.1.0-unstable-2025-03-05";

  src = inputs.cosmic-ext-applet-clipboard-manager.outPath;

  # useFetchCargoVendor = true;
  cargoHash = "sha256-Ynqb71OnHULvouvulBKQBo41j61aQpLoHnCJwJihTrY=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "env-dst"
    "${placeholder "out"}/etc/profile.d/cosmic-ext-applet-clipboard-manager.sh"
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-clipboard-manager"
  ];

  preCheck = ''
    export XDG_RUNTIME_DIR="$TMP"
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
}