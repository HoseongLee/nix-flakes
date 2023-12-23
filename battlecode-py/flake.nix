{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      python3Optimized = pkgs.python3.override {
        enableLTO = true;
        enableOptimizations = true;
        reproducibleBuild = false;
        self = python3Optimized;
      };

      NEAT = pkgs.python3Packages.buildPythonPackage rec {
        pname = "neat-python";
        version = "0.92";

        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-vnIqYtBTs5/pYCKOPguv/evnMHQTPOQLvTXeZQylOg8=";
        };
      };

      libs = [
        NEAT
      ];

      tools = with pkgs; [
        python3Optimized
      ];
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = libs ++ tools;

        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath libs}";
      };
    };
}
