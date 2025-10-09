{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    # Does this fail for you? You need Nix 2.27:
    # https://nix.dev/manual/nix/2.27/release-notes/rl-2.27.html
    # Workaround: Install Nix with Nix (e.g. nix run nixpkgs#nix).
    self.submodules = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-tree;
        packages = rec {
          site =
            pkgs.runCommand "site"
              {
                nativeBuildInputs = [ pkgs.hugo ];
              }
              ''
                # Can't get Hugo to not try to modify the source tree, so copy it
                # somewhere writable.
                writableSrc=$(mktemp -d)
                cp -R ${./.}/* "$writableSrc"

                hugo build \
                  --cacheDir $(mktemp -d) \
                  --destination $out \
                  --source "$writableSrc" \
                  --minify
              '';
          default = site;
        };

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.hugo ];
        };
      }
    );
}
