{ inputs, self }:
{
  mkNixosWorkstation =
    {
      flakeDir,
      hostname,
      system,
      user,
      modules ? [ ],
      extraUserModules ? [ ],
      wslMachine ? false,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs system user;
      };
      modules =
        modules
        ++ [
          { nixpkgs.hostPlatform = system; }
          "${flakeDir}/hosts/workstations/${hostname}/configuration.nix"
          "${self}/shared/base/default.nix"
          "${self}/shared/base/nixos.nix"
          "${self}/shared/workstations/all/default.nix"
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs system user;
              };
              users.${user} = {
                imports =
                  [
                    "${flakeDir}/hosts/workstations/${hostname}/home.nix"
                    "${self}/shared/workstations/all/home.nix"
                  ]
                  ++ extraUserModules
                  ++ (
                    if wslMachine then
                      [ "${self}/shared/workstations/wsl/home.nix" ]
                    else
                      [ "${self}/shared/workstations/nixos/home.nix" ]
                  );
              };
            };
          }
        ]
        ++ (
          if wslMachine then
            [
              inputs.nixos-wsl.nixosModules.default
              "${self}/shared/workstations/wsl/default.nix"
            ]
          else
            [ "${self}/shared/workstations/nixos/default.nix" ]
        );
    };

  mkDarwinWorkstation =
    {
      flakeDir,
      hostname,
      system,
      user,
      modules ? [ ],
      extraUserModules ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs system user;
      };
      modules = modules ++ [
        { nixpkgs.hostPlatform = system; }
        "${flakeDir}/hosts/workstations/${hostname}/configuration.nix"
        "${self}/shared/base/default.nix"
        "${self}/shared/workstations/darwin/default.nix"
        "${self}/shared/workstations/all/default.nix"
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit inputs system user;
            };
            users.${user} = {
              imports =
                [
                  "${flakeDir}/hosts/workstations/${hostname}/home.nix"
                  "${self}/shared/workstations/darwin/home.nix"
                  "${self}/shared/workstations/all/home.nix"
                ]
                ++ extraUserModules;
            };
          };
        }
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = user;
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }
        "${self}/shared/workstations/darwin/homebrew.nix"
      ];
    };

  # Server builder
  mkNixosServer =
    {
      flakeDir,
      hostname,
      system,
      modules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs system;
      };
      modules = modules ++ [
        { nixpkgs.hostPlatform = system; }
        "${flakeDir}/hosts/servers/${hostname}/configuration.nix"
        "${self}/shared/base/default.nix"
        "${self}/shared/base/nixos.nix"
      ];
    };
}
