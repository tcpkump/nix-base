{ inputs, pkgs }:

let
  system = pkgs.stdenv.hostPlatform.system;
  llm-agents = inputs.llm-agents.packages.${system};
in

with pkgs;
[
  # Neovim
  inputs.nixcats-config.packages.${system}.default

  python3

  pre-commit
  google-cloud-sdk
  openssl

  # LLM tools (from llm-agents.nix)
  llm-agents.claude-code
  llm-agents.codex

  # LSP/formatter
  nixd
  nixfmt

  # kubernetes related
  argocd
  cmctl
  fluxcd
  k9s
  kubectl

  podman
  podman-compose

  # archives
  zip
  unzip
  p7zip

  # utils
  fd
  imagemagickBig
  jq
  ripgrep
  wget
  yq-go

  # networking tools
  nmap # A utility for network discovery and security auditing

  # misc
  btop
  gcc
  gh
  gnumake
  gnupg
  killall
  tree
  which

  # Security and authentication
  bitwarden-cli
  git-credential-manager
  libfido2
  pass
  yubikey-agent

  # manuals
  man-pages
  man-pages-posix
]
