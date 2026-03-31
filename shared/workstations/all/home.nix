{
  pkgs,
  inputs,
  user,
  ...
}:
{
  home.username = user;
  home.packages = import ./packages.nix { inherit inputs pkgs; };
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.file = {
    ".terraformrc".source = ./config/terraformrc;
    ".config/scripts/tmux-project-switcher.sh".source = ./scripts/tmux-project-switcher.sh;
    # snacks.nvim lazygit integration writes a theme file here at runtime
    ".cache/nvim/.keep".text = "";
  };

  programs = {
    neovim.defaultEditor = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          # TODO: filter this down to trusted endpoints?
          addKeysToAgent = "yes";
          # from home-manager documentation https://home-manager-options.extranix.com/?query=programs.ssh&release=master
          forwardAgent = false;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        # improves listing
        column.ui = "auto";
        branch.sort = "committerdate";
        tag.sort = "version:refname";

        # general preference
        core = {
          editor = "nvim";
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        init.defaultBranch = "main";
        help.autocorrect = "prompt";
      };
      ignores = [
        ".envrc"
        ".direnv/"
        ".claude/"
        "CLAUDE.md"
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux = {
        enableShellIntegration = true;
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bash.enable = true; # nix-direnv requires modern bash
    awscli.enable = true;
    go.enable = true;

    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_address = "https://api.atuin.sh";
        sync_frequency = "5m";

        inline_height = 15;
        search_mode_shell_up_key_binding = "prefix";
        style = "compact";

        show_help = false;
        show_preview = false;
        show_tabs = false;
      };
    };

    tmux = {
      enable = true;
      sensibleOnTop = false;
      shell = "${pkgs.zsh}/bin/zsh";
      plugins = with pkgs; [
        tmuxPlugins.pass
      ];
    };

    ghostty = {
      enableZshIntegration = true;
      settings = {
        theme = "Kanagawa Wave";
        font-family = "Hack Nerd Font Mono";
        keybind = [
          "alt+one=unbind"
          "alt+two=unbind"
          "alt+three=unbind"
          "alt+four=unbind"
          "alt+five=unbind"
          "alt+six=unbind"
          "alt+seven=unbind"
          "alt+eight=unbind"
          "alt+nine=unbind"
        ];
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = "$time$cmd_duration$directory$git_branch$git_status$git_state$character";
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
        directory = {
          format = " [$path]($style)[$read_only]($read_only_style)";
          style = "bold cyan";
        };
        git_branch = {
          symbol = "";
          style = "bold purple";
          format = " branch:\\([$symbol$branch]($style)\\)";
        };
        git_status = {
          format = " git:\\([$all_status$ahead_behind]($style)\\)";
          style = "bold white";
          conflicted = "[⚡](bold red)";
          ahead = "[⇡\${count}](bold blue)";
          behind = "[⇣\${count}](bold blue)";
          diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](bold blue)";
          untracked = "[?](bold white)";
          stashed = "[📦](bold cyan)";
          modified = "[!](bold red)";
          staged = "[+](bold yellow)";
          renamed = "[»](bold green)";
          deleted = "[✘](bold red)";
        };
        git_state = {
          format = " git_state:\\([$state( $progress_current/$progress_total)]($style)\\)";
          style = "bright-black";
        };
        time = {
          disabled = false;
          format = "[$time]($style)";
        };
        cmd_duration = {
          format = " cmd took [$duration]($style)";
          show_notifications = false;
        };
        # Disable modules we don't want
        aws = {
          disabled = true;
        };
        gcloud = {
          disabled = true;
        };
        nodejs = {
          disabled = true;
        };
        python = {
          disabled = true;
        };
        rust = {
          disabled = true;
        };
        golang = {
          disabled = true;
        };
        php = {
          disabled = true;
        };
        lua = {
          disabled = true;
        };
        package = {
          disabled = true;
        };
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        "vim" = "nvim";

        "ls" = "ls --color=auto";
        "ll" = "ls -lhF --color=auto";
        "la" = "ls -lhFa --color=auto";

        "tf" = "terraform";
        "tfi" = "terraform init -upgrade";
        "tfp" = "terraform plan";
        "tfa" = "terraform apply";
        "tfd" = "terraform destroy";
        "tff" = "terraform fmt -recursive";

        "k" = "kubectl";
      };
      envExtra = ''
        export EDITOR=nvim
        export LANG=en_US.UTF-8
        unset LC_ALL

        export PATH="$PATH:$HOME/go/bin/"
        export PATH="$PATH:$HOME/.local/bin"

        # https://github.com/hashicorp/terraform/issues/32936
        export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

        # https://github.com/tofuutils/tenv/issues/328
        export TENV_DETACHED_PROXY=false

        # https://github.com/derailed/k9s/issues/1001#issuecomment-2447445306
        export K9S_FEATURE_GATE_NODE_SHELL=true
      '';

      history.size = 10000;

      # Performance optimizations
      completionInit = "autoload -U compinit && compinit -C";

      initContent = ''
        # Completion performance
        zstyle ':completion:*' use-cache yes
        zstyle ':completion:*' cache-path ~/.zsh/cache
        zstyle ':completion:*' accept-exact '*(N)'
        zstyle ':completion:*' squeeze-slashes true

        # Case-insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

        ulimit -n 4096 # nix rebuilds need to open many files

        # Check if tmux is installed
        if [ -x "$(command -v tmux)" ] && [ -z "''${TMUX}" ]; then
          # For NixOS (Linux), check for DISPLAY
          if [[ "$(uname)" == "Linux" && -n "''${DISPLAY}" ]]; then
            exec tmux new-session -A -s ''${USER} >/dev/null 2>&1
          # For macOS, check for interactive session
          elif [[ "$(uname)" == "Darwin" && -t 0 ]]; then
            exec tmux new-session -A -s ''${USER} >/dev/null 2>&1
          fi
        fi

        function vpn() {
            case "$1" in
                connect)
                    if [[ -n "$2" ]]; then
                        # Disconnect all sessions first
                        vpn disconnect

                        # Start a new VPN session
                        echo "Connecting to $2..."
                        openvpn3 session-start --config ~/Sync/"$2.ovpn"
                    else
                        echo "Please specify a VPN profile name to connect."
                    fi
                    ;;

                disconnect)
                    echo "Disconnecting all VPN sessions..."
                    # Fetch the session paths and disconnect each session
                    local sessions=$(openvpn3 sessions-list | grep -oP 'Path: \\K/net/openvpn/v3/sessions/\\S+')
                    for session in $sessions; do
                        openvpn3 session-manage --session-path="$session" --disconnect
                    done
                    ;;

                list)
                    echo "Available VPN profiles:"
                    ls ~/Sync/*.ovpn | sed 's|^.*/||; s|\\.ovpn$||'
                    ;;

                *)
                    echo "Usage: vpn [connect <name> | disconnect | list]"
                    ;;
            esac
        }

        flakify() {
            # Configuration
            local default_template="github:nix-community/nix-direnv"
            local official_flake_url="github:NixOS/templates"

            # Create flake.nix if it doesn't exist
            if [ ! -e flake.nix ]; then
                local template_to_use=""

                if [ -n "$1" ]; then
                    local template_name="$1"

                    # Try official repo
                    if nix flake show --json --quiet --no-warn-dirty "$official_flake_url" 2>/dev/null |
                            jq -e --arg name "$template_name" '.templates[$name] != null' >/dev/null 2>&1; then
                        template_to_use="$official_flake_url#$template_name"
                        echo "Using template '$template_name' from official repo"
                    else
                        echo "Error: Template '$template_name' not found" >&2
                        return 1
                    fi
                else
                    # Use default template
                    template_to_use="$default_template"
                    echo "No template specified, using default: $default_template"
                fi

                # Create flake using template
                if ! nix flake new --quiet --template "$template_to_use" .; then
                    echo "Error: Failed to create flake" >&2
                    return 1
                fi
                echo "flake.nix created successfully"
            fi

            # Create .envrc if needed
            if [ ! -e .envrc ]; then
                echo "source_up_if_exists" >> .envrc
                echo "use flake" >> .envrc
                echo ".envrc created"
            fi

            # Open in editor
            if [ -n "$EDITOR" ]; then
                echo "Opening flake.nix in $EDITOR"
                $EDITOR flake.nix
            else
                echo "Warning: \$EDITOR not set. Please edit flake.nix manually."
            fi
        }

        vaultgrep() {
            if [ -z "$1" ]; then
                echo "# ERROR: Need a search string!"
                return 1
            fi

            searchfor="$1"
            # Find all vault.yml files in the current directory and subdirectories
            find . -name 'vault.yml' | while read -r vaultfile; do
                # Use ansible-vault to view the contents and grep for the search term
                OUTPUT=$(ansible-vault view "$vaultfile" | grep "$searchfor")
                if [ -n "$OUTPUT" ]; then
                    echo "$vaultfile: $OUTPUT"
                fi
            done
        }

        aws-export() {
            eval $(aws configure export-credentials --format env)
            echo "AWS credentials have been exported to your shell session."
        }

        # Check for pre-commit-config when changing into dir
        cd() {
          builtin cd "$@"
          if [[ -d .git && -f .pre-commit-config.yaml && ! -f .git/hooks/pre-commit ]]; then
            echo "Pre-commit config found. Installing hooks..."
            pre-commit install
          fi
        }
      '';
    };
  };
}
