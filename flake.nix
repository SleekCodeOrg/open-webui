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
        
        # Python package (deprecated, use docker apps instead)
        open-webui-dev = pkgs.callPackage ./nix/package.nix {
          src = self;
        };

        dockerBuild = pkgs.writeShellApplication {
          name = "docker-build";
          text = ''
            docker build --tag open-webui-local .
          '';
          runtimeInputs = [ pkgs.docker ];
        };

        dockerRun = pkgs.writeShellApplication {
          name = "docker-run";
          text = ''
            docker run -d \\
              --name open-webui \\
              -p 3000:8080 \\
              -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \\
              -v /home/jjs/proj/work/gartner/open-webui/data:/app/backend/data \\
              open-webui-local
          '';
          runtimeInputs = [ pkgs.docker ];
        };

      in {
        packages = {
          default = dockerBuild;
          dockerBuild = dockerBuild;
          dockerRun = dockerRun;
          open-webui-dev = open-webui-dev;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
        packages = with pkgs; [ docker ] ++ (with pkgs; [
          nodejs_20
          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.npm
            python3
            python3Packages.pip
            python3Packages.virtualenv
            python3Packages.hatchling
            git
            jq
            ffmpeg-headless
          ];

          shellHook = ''
            echo "🚀 Open-WebUI Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
          echo "Docker: nix run .#docker-build"
          echo "Run: nix run .#docker-run"
          echo "Frontend: npm install && npm run dev"
          echo "Backend:  cd backend && python main.py"
          echo ""
            
            export OLLAMA_BASE_URL="http://localhost:11434"
            export NODE_OPTIONS="--max-old-space-size=8192"
            export CYPRESS_INSTALL_BINARY="0"
            export ONNXRUNTIME_NODE_INSTALL_CUDA="skip"
          '';
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = dockerBuild;
          };
          docker-build = flake-utils.lib.mkApp {
            drv = dockerBuild;
          };
          docker-run = flake-utils.lib.mkApp {
            drv = dockerRun;
          };
          open-webui-dev = flake-utils.lib.mkApp {
            drv = open-webui-dev;
            exePath = "/bin/open-webui";
          };
        };
      }
    );
}
