{
  description = "nix-entry-plug — NixOS + home-manager flake for the Eva fleet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management (not yet wired into any module)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unified system-wide theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Browsers — flakes ship their own home-manager / NixOS modules.
    # Both flakes' READMEs recommend pinning their nixpkgs (and zen's
    # home-manager) to ours to avoid double-evaluation drift.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Git hook integration (statix, deadnix, nixfmt).
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Multi-formatter runner
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ephemeral root (future phase)
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      treefmt-nix,
      git-hooks,
      ...
    }@inputs:
    let
      # All current hosts are x86_64-linux. Expand to a `forAllSystems`
      # helper if/when another architecture joins the fleet.
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pass `inputs` and `self` to every NixOS and home-manager module
      # so they can reach flake inputs (disko, stylix, browsers, etc.)
      # without re-importing the flake.
      moduleArgs = { inherit inputs self; };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      preCommitCheck = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # `nixfmt-rfc-style` is now an alias of `nixfmt`; use the canonical key.
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };
    in
    {
      nixosConfigurations = {
        unit-01 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = moduleArgs;
          modules = [
            ./hosts/unit-01
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = moduleArgs;
              };
            }
          ];
        };
      };

      # `nix fmt` → treefmt wrapper.
      formatter.${system} = treefmtEval.config.build.wrapper;

      # `nix flake check` runs these.
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
        pre-commit = preCommitCheck;
      };

      # `nix develop` (and direnv via `.envrc`) drop you into this shell.
      devShells.${system}.default = pkgs.mkShell {
        # Installs pre-commit hooks into .git/hooks on shell entry.
        inherit (preCommitCheck) shellHook;
        packages = [
          treefmtEval.config.build.wrapper
          pkgs.nh
          pkgs.nix-output-monitor
          pkgs.nvd
          pkgs.just
          pkgs.statix
          pkgs.deadnix
        ];
      };
    };
}
