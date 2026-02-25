{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter =
          let
            cfg = treefmt-nix.lib.evalModule pkgs {
              projectRootFile = "flake.nix";
              programs.nixfmt.enable = true;
              programs.mdformat.enable = true;
            };
          in
          cfg.config.build.wrapper;

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
          packages = with pkgs; [ hugo markdownlint-cli2 ];
        };

        checks.markdown-lint =
          pkgs.runCommand "markdown-lint"
            {
              buildInputs = [ pkgs.markdownlint-cli2 ];
            }
            ''
              markdownlint-cli2 "${self}/**/*.md"
              touch $out
            '';
      }
    );
}
