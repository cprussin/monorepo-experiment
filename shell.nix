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

  hlb-overlay = self: _: {
    hlb = self.buildGoModule {
      pname = "hlb";
      version = "0.0.2";

      src = self.fetchFromGitHub {
        owner = "openllb";
        repo = "hlb";
        rev = "9f539ffb6c7a1722e54e2b079251d58ff9dac7fb";
        sha256 = "1dv4d5n0bc3nx4cm1k03b1r50qdvg0n0qd79mf3fp8sa66mw2zf4";
      };

      modSha256 = "19xp4ki9wi1jd7q7s3rvcx8xy0bb92s8vpkb5vyd47yfhqa1xpls";
    };
  };

  pkgs = import nixpkgs {
    overlays = [
      niv-overlay
      hlb-overlay
    ];
  };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.niv
    pkgs.nodejs
    pkgs.yarn
    pkgs.hlb
  ];
}
