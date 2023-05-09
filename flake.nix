{
  description = "Catalyst experimenting stuff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-mozilla, rust-overlay, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let

          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import nixpkgs-mozilla) (import rust-overlay) ];
            config.allowUnfree = true; # mongodb is not FOSS
          };

          installKani = pkgs.writeShellScriptBin "install-kani" ''
            cargo install kani-verifier --version 0.22.0
            CURL_CA_BUNDLE=/etc/ssl/certs/ca-bundle.crt cargo kani setup 
            echo "make sure $HOME/.cargo/bin is on the path"
          '';

          # get the rust toolchain version from the `rust-toolchain.toml` file
          /* rustToolchain = (pkgs.rustChannelOf { */
          /*   rustToolchain = ./rust-toolchain.toml; */
          /*   # when bumping versions, copy the hash from the error and put it here */
          /*   sha256 = "sha256-JvgrOEGMM0N+6Vsws8nUq0W/PJPxkf5suZjgEtAzG6I="; */
          /* }).rust; */

          nativeBuildInputs = with pkgs; [
            /* rustToolchain */
            (rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
            })
            mongodb
            mongodb-compass

            protobuf

            installKani
            (pkgs.python3.withPackages (packages: [
              packages.pip
            ]))
          ];

          naersk = pkgs.callPackage inputs.naersk {
            /* cargo = rustToolchain; */
            /* rustc = rustToolchain; */
          };

          buildCrate = crateName: naersk.buildPackage {
            src = ./.;
            pname = crateName;
            inherit nativeBuildInputs;
          };

        in

        {
          packages.hermes = buildCrate "hermes";

          devShells.default = pkgs.mkShell {
            inherit nativeBuildInputs;
          };
        }

      );
}
