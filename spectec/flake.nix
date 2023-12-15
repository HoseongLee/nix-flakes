{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      ocamlLib = with pkgs.ocaml-ng.ocamlPackages_5_0; [
        ocaml

        findlib
        mdx
        menhir
      ];

      ocamlBuildTools = with pkgs; [
        dune_3
        sphinx
      ];
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = ocamlLib ++ ocamlBuildTools;

        shellHook = ''
          zsh
        '';
      };
    };
}
