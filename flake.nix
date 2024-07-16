{
  description = "pear-chess dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ruby-nix.url = "github:inscapist/ruby-nix";
    # a fork that supports platform dependant gem
    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    bob-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    bob-ruby.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ruby-nix,
      bundix,
      bob-ruby,
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bob-ruby.overlays.default ];
        };
        rubyNix = ruby-nix.lib pkgs;

        gemset = if builtins.pathExists ./gemset.nix then import ./gemset.nix else { };

        # See available versions here: https://github.com/bobvanderlinden/nixpkgs-ruby/blob/master/ruby/versions.json
        ruby = pkgs."ruby-3.3.4";

        # Running bundix would regenerate `gemset.nix`
        bundixcli = bundix.packages.${system}.default;
      in
        rec {
          inherit
            (rubyNix {
              gemset = gemset;
              ruby = ruby;
              name = "pear-chess";
              gemConfig = pkgs.defaultGemConfig;
            })
            env
          ;

          devShells = rec {
            default = dev;
            dev = pkgs.mkShell {
              buildInputs =
                [
                  env
                  bundixcli
                ];
            };
          };
        }
    );
}
