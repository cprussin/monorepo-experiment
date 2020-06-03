let
  sources = import ./sources.nix;
in

{
  niv ? sources.niv,
  nixpkgs ? sources.nixpkgs
}:

let
  niv-overlay = self: _: {
    niv = niv.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ self.makeWrapper ];
      postInstall = ''
        ${oldAttrs.postInstall or ""}
        wrapProgram $out/bin/niv \
          --add-flags "--sources-file ${toString ./sources.json}"
      '';
    });
  };

  pkgs = import nixpkgs {
    overlays = [
      niv-overlay
    ];
  };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.niv
    pkgs.nodejs
    pkgs.yarn
  ];
}
