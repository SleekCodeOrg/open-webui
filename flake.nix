{
  description = "Open-WebUI development fork";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Build the package using the nix/package.nix file
        open-webui-dev = pkgs.callPackage ./nix/package.nix {
          src = self;
        };

      in {
        packages = {
          default = open-webui-dev;
          open-webui = open-webui-dev;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.npm
            python3
            python3Packages.pip
            python3Packages.virtualenv
            python3Packages.hatchling
            git
            jq
            python3Packages.langchain
            ffmpeg-headless
          ];

          shellHook = ''
            echo "🚀 Open-WebUI Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Frontend: npm install && npm run dev"
            echo "Backend:  cd backend && python main.py"
            echo ""
            
            export OLLAMA_BASE_URL="http://localhost:11434"
            export NODE_OPTIONS="--max-old-space-size=8192"
            export CYPRESS_INSTALL_BINARY="0"
            export ONNXRUNTIME_NODE_INSTALL_CUDA="skip"
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = open-webui-dev;
          exePath = "/bin/open-webui";
        };
      }
    );
}
