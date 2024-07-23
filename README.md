# README

## About

2v2 chess where moves are executed in parallel.

## Development

### Setup

- Install [nix](https://nix.dev/install-nix#install-nix).
- Enable flakes by adding `experimental-features = nix-command flakes` to `nix.conf` (either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`).
- Run `nix develop` to open a development shell.
  - Run `nix develop -c zsh` for zsh.
  - Run `nix develop -c kitten run-shell --shell=zsh` for kitty's shell integration to work.

### Add a new gem

- Run `bundle add gem_name --skip-install` to add gem to `Gemfile`.
- Run `bundle lock` to update the `Gemfile.lock` to include the new gem.
- Run `bundix` to generate a new `gemset.nix` from the updated `Gemfile.lock`.
- Exit the dev shell and re-enter using `nix develop` to install the new dependencies in `gemset.nix`.
