{
  description = "Ellen's NixOS desktop (Hyprland + Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-nix = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Do NOT add inputs.nixpkgs.follows to chaotic.
    # Chaotic Nyx pins its own nixpkgs; overriding it causes the kernel store
    # path to differ from the binary cache and triggers a from-source build.
    # chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, sops-nix, disko, catppuccin, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/desktop/default.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          catppuccin.nixosModules.catppuccin
          # inputs.chaotic.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [
              catppuccin.homeModules.catppuccin
            ];
            home-manager.users.ellen = import ./modules/home/default.nix;
          }
        ];
      };
    };
}
